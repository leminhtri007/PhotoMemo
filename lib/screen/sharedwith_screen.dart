import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photomemoapp/controller/firebasecontroller.dart';
import 'package:photomemoapp/model/photocomment.dart';
import 'package:photomemoapp/screen/comment_screen.dart';
import 'package:photomemoapp/screen/myview/mydialog.dart';

import '../model/constant.dart';
import '../model/photomemo.dart';
import 'myview/myimage.dart';

class SharedWithScreen extends StatefulWidget {
  static const routeName = '/sharedWithScreen';
  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }
}

class _SharedWithState extends State<SharedWithScreen> {
  _Controller con;
  User user;
  List<PhotoComment> photoCommentList;
  List<PhotoMemo> photoMemoList;

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Shared With Me'),
      ),
      body: photoMemoList.length == 0
          ? Text(
              'No PhotoMemos shared with me',
              style: Theme.of(context).textTheme.headline5,
            )
          : ListView.builder(
              itemCount: photoMemoList.length,
              itemBuilder: (context, index) => Card(
                elevation: 7.0,
                child: ListTile(
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: MyImage.network(
                              url: photoMemoList[index].photoURL, context: context),
                        ),
                      ),
                      Text(
                        'Title: ${photoMemoList[index].title}',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Text('Memo: ${photoMemoList[index].memo}'),
                      Text('Created By: ${photoMemoList[index].createdBy}'),
                      Text('Updated At: ${photoMemoList[index].timestamp}'),
                      Text('Shared With: ${photoMemoList[index].sharedWith}'),
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
  _SharedWithState state;
  _Controller(this.state);
  int delIndex;

  void onTap(int index) async {
    if (delIndex != null) return;
    try {
      List<PhotoComment> photoCommentList = await FirebaseController.getPhotoCommentList(
        photoId: state.photoMemoList[index].docId,
      );
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
        title: 'get Photo Comment error',
        content: '$e',
      );
    }

    state.render(() {});
  }
}
