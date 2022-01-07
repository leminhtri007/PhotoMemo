import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photomemoapp/controller/firebasecontroller.dart';
import 'package:photomemoapp/model/constant.dart';
import 'package:photomemoapp/model/notification.dart';
import 'package:photomemoapp/model/photocomment.dart';
import 'package:photomemoapp/model/photomemo.dart';
import 'package:photomemoapp/screen/comment_screen.dart';
import 'package:photomemoapp/screen/myview/mydialog.dart';
import 'package:photomemoapp/screen/myview/myimage.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = '/notificationScreen';
  @override
  State<StatefulWidget> createState() {
    return _NotificationScreenState();
  }
}

class _NotificationScreenState extends State<NotificationScreen> {
  _Controller con;
  User user;
  List<PhotoMemo> photoMemoList;
  List<PhotoComment> photoCommentList;
  List<NotificationComment> notificationCommentList;

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
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];
    photoCommentList ??= args[Constant.ARG_PHOTO_COMMENT_LIST];
    notificationCommentList ??= args[Constant.ARG_NOTIFICATION_COMMENT_LIST];
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
      ),
      body: notificationCommentList.length == 0
          ? Text(
              'No Notification',
              style: Theme.of(context).textTheme.headline5,
            )
          : ListView.builder(
              itemCount: notificationCommentList.length,
              itemBuilder: (context, index) => Card(
                elevation: 7.0,
                child: ListTile(
                  leading: MyImage.network(
                      url: notificationCommentList[index].photoURL, context: context),
                  subtitle: Column(
                    children: [
                      Text(
                          '${notificationCommentList[index].email} commented on your photo:'),
                      Text(
                        '"${notificationCommentList[index].content}"',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ],
                  ),
                  onTap: () => con.onTap(index),
                ),
              ),
            ),
    );
  }
}

class _Controller {
  _NotificationScreenState state;
  _Controller(this.state);
  int delIndex;

  void onTap(int index) async {
    try {
      List<PhotoComment> photoCommentList = await FirebaseController.getPhotoCommentList(
        photoId: state.notificationCommentList[index].photoId,
      );
      NotificationComment n = state.notificationCommentList[index];
      await FirebaseController.deleteNotification(n);
      state.render(() {
        state.notificationCommentList.removeAt(index);
      });
      await Navigator.pushNamed(
        state.context,
        CommentScreen.routeName,
        arguments: {
          Constant.ARG_USER: state.user,
          Constant.ARG_ONE_PHOTOMEMO: state.photoMemoList[index],
          Constant.ARG_PHOTO_COMMENT_LIST: photoCommentList,
        },
      );
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Delete PhotoMemo',
        content: '$e',
      );
    }
    state.render(() {});
  }
}
