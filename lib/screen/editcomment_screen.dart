import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photomemoapp/controller/firebasecontroller.dart';
import 'package:photomemoapp/model/constant.dart';
import 'package:photomemoapp/model/photocomment.dart';
import 'package:photomemoapp/model/photomemo.dart';
import 'package:photomemoapp/screen/myview/mydialog.dart';

class EditCommentScreen extends StatefulWidget {
  static const routeName = '/editCommentScreen';
  @override
  State<StatefulWidget> createState() {
    return _EditCommentState();
  }
}

class _EditCommentState extends State<EditCommentScreen> {
  _Controller con;
  User user;
  PhotoComment onePhotoComment;
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
    onePhotoComment ??= args[Constant.ARG_ONE_PHOTO_COMMENT];
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Comment'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: con.update,
          )
        ],
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: TextFormField(
            style: Theme.of(context).textTheme.headline6,
            initialValue: '${onePhotoComment.content}',
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
  _EditCommentState state;
  _Controller(this.state);
  PhotoComment tempComment = PhotoComment();

  void update() async {
    if (!state.formKey.currentState.validate()) return;

    state.formKey.currentState.save();
    try {
      MyDialog.circularProgressStart(state.context);
      Map<String, dynamic> updateInfo = {};
      updateInfo[PhotoComment.EMAIL] = state.onePhotoComment.email;
      updateInfo[PhotoComment.PHOTO_ID] = state.onePhotoComment.photoId;
      updateInfo[PhotoComment.CONTENT] = tempComment.content;
      updateInfo[PhotoComment.TIMESTAMP] = DateTime.now();
      await FirebaseController.updatePhotoComment(
          state.onePhotoComment.docId, updateInfo);
      MyDialog.circularProgessStop(state.context);
      Navigator.pop(state.context);
    } catch (e) {
      MyDialog.circularProgessStop(state.context);
      MyDialog.info(context: state.context, title: 'Update Photo Error', content: '$e');
    }
    // state.render(() {});
  }

  void saveComment(String value) {
    tempComment.content = value;
  }
}
