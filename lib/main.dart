import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photomemoapp/model/constant.dart';
import 'package:photomemoapp/screen/addphotomemo_screen.dart';
import 'package:photomemoapp/screen/comment_screen.dart';
import 'package:photomemoapp/screen/editcomment_screen.dart';
import 'package:photomemoapp/screen/notification_screen.dart';
import 'package:photomemoapp/screen/sharedwith_screen.dart';
import 'package:photomemoapp/screen/signin_screen.dart';
import 'package:photomemoapp/screen/signup_screen.dart';
import 'package:photomemoapp/screen/userhome_screen.dart';
import 'package:photomemoapp/screen/detailedview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PhotoMemoApp());
}

class PhotoMemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: Constant.DEV,
      theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.blue),
      initialRoute: SignInScreen.routeName,
      routes: {
        SignInScreen.routeName: (context) => SignInScreen(),
        UserHomeScreen.routeName: (context) => UserHomeScreen(),
        AddPhotoMemoScreen.routeName: (context) => AddPhotoMemoScreen(),
        DetailedViewScreen.routeName: (context) => DetailedViewScreen(),
        SignUpScreen.routeName: (context) => SignUpScreen(),
        SharedWithScreen.routeName: (context) => SharedWithScreen(),
        CommentScreen.routeName: (context) => CommentScreen(),
        NotificationScreen.routeName: (context) => NotificationScreen(),
        EditCommentScreen.routeName: (context) => EditCommentScreen(),
      },
    );
  }
}
