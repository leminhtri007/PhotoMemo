import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photomemoapp/controller/firebasecontroller.dart';
import 'package:photomemoapp/model/constant.dart';
import 'package:photomemoapp/model/notification.dart';
import 'package:photomemoapp/model/photocomment.dart';
import 'package:photomemoapp/model/photomemo.dart';
import 'package:photomemoapp/screen/editcomment_screen.dart';
import 'package:photomemoapp/screen/myview/mydialog.dart';
import 'package:photomemoapp/screen/myview/myimage.dart';

class CommentScreen extends StatefulWidget {
  static const routeName = '/commentScreen';
  @override
  State<StatefulWidget> createState() {
    return _CommentScreenState();
  }
}

class _CommentScreenState extends State<CommentScreen> {
  _Controller con;
  User user;
  List<PhotoComment> photoCommentList;
  List<NotificationComment> notificationCommentList;
  PhotoMemo onePhotoMemo;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    onePhotoMemo ??= args[Constant.ARG_ONE_PHOTOMEMO];
    photoCommentList ??= args[Constant.ARG_PHOTO_COMMENT_LIST];
    notificationCommentList ??= args[Constant.ARG_NOTIFICATION_COMMENT_LIST];
    return Scaffold(
      appBar: AppBar(
        title: Text("Comment"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: MyImage.network(
                  url: onePhotoMemo.photoURL,
                  context: context,
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            photoCommentList.length == 0
                ? Text(
                    'No Comment',
                    style: Theme.of(context).textTheme.headline5,
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: photoCommentList.length,
                    itemBuilder: (context, index) => Card(
                      elevation: 7.0,
                      child: ListTile(
                        subtitle: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${photoCommentList[index].email} At ${photoCommentList[index].timestamp.toString()} :',
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${photoCommentList[index].content}',
                                    style: Theme.of(context).textTheme.headline6,
                                  ),
                                  user.email != photoCommentList[index].email
                                      ? SizedBox()
                                      : Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit),
                                              onPressed: () => con.editComment(index),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () => con.deleteComment(index),
                                            )
                                          ],
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: Form(
        key: formKey,
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: TextFormField(
            style: Theme.of(context).textTheme.headline6,
            decoration: InputDecoration(
              hintText: 'Write Comments...',
              suffixIcon: IconButton(
                icon: Icon(Icons.forward_rounded),
                onPressed: con.save,
              ),
            ),
            autocorrect: false,
            validator: PhotoMemo.validateTitle,
            onSaved: con.saveComment,
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _CommentScreenState state;
  _Controller(this.state);
  PhotoComment tempComment = PhotoComment();
  NotificationComment tempNotification = NotificationComment();
  int count = 0;

  void save() async {
    if (!state.formKey.currentState.validate()) return;
    state.formKey.currentState.save();

    MyDialog.circularProgressStart(state.context);

    try {
      if (state.user.email == state.onePhotoMemo.createdBy) {
        tempComment.photoId = state.onePhotoMemo.docId;
        tempComment.email = state.user.email;
        tempComment.timestamp = DateTime.now();
        String docId = await FirebaseController.addPhotoComment(tempComment);
        tempComment.docId = docId;
        state.photoCommentList.insert(0, tempComment);
        MyDialog.circularProgessStop(state.context);
      } else {
        tempNotification.photoId = state.onePhotoMemo.docId;
        tempNotification.ownerEmail = state.onePhotoMemo.createdBy;
        tempNotification.email = state.user.email;
        tempNotification.timestamp = DateTime.now();
        tempNotification.photoURL = state.onePhotoMemo.photoURL;
        tempNotification.content = tempComment.content;
        String docId = await FirebaseController.addNotifyComment(tempNotification);
        tempNotification.docId = docId;
        tempComment.photoId = state.onePhotoMemo.docId;
        tempComment.email = state.user.email;
        tempComment.timestamp = DateTime.now();
        docId = await FirebaseController.addPhotoComment(tempComment);
        tempComment.docId = docId;
        state.photoCommentList.insert(0, tempComment);
        MyDialog.circularProgessStop(state.context);
      }
    } catch (e) {
      MyDialog.circularProgessStop(state.context);
      MyDialog.info(
        context: state.context,
        title: 'Save PhotoComment error',
        content: '$e',
      );
    }
    state.formKey.currentState.reset();
    FocusScope.of(state.context).unfocus();
    state.render(() {});
  }

  void saveComment(String value) {
    tempComment.content = value;
  }

  void editComment(int index) async {
    await Navigator.pushNamed(
      state.context,
      EditCommentScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_ONE_PHOTO_COMMENT: state.photoCommentList[index],
      },
    );
    state.render(() {});
  }

  void deleteComment(int index) async {
    try {
      PhotoComment c = state.photoCommentList[index];
      await FirebaseController.deleteComment(c);
      state.render(() {
        state.photoCommentList.removeAt(index);
      });
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Delete Comment',
        content: '$e',
      );
    }
  }
}
