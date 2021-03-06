import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:photomemoapp/model/constant.dart';
import 'package:photomemoapp/model/notification.dart';
import 'package:photomemoapp/model/photocomment.dart';
import 'package:photomemoapp/model/photomemo.dart';

import '../model/constant.dart';
import '../model/photomemo.dart';

class FirebaseController {
  static Future<User> signIn({@required String email, @required String password}) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  static Future<void> createAccount(
      {@required String email, @required String password}) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<Map<String, String>> uploadPhotoFile({
    @required File photo,
    String filename,
    @required String uid,
    @required Function listener,
  }) async {
    filename ??= '${Constant.PHOTOIMAGE_FOLDER}/$uid/${DateTime.now()}';
    UploadTask task = FirebaseStorage.instance.ref(filename).putFile(photo);
    task.snapshotEvents.listen((TaskSnapshot event) {
      double progress = event.bytesTransferred / event.totalBytes;
      if (event.bytesTransferred == event.totalBytes) progress = null;
      listener(progress);
    });
    await task;
    String downloadURL = await FirebaseStorage.instance.ref(filename).getDownloadURL();
    return <String, String>{
      Constant.ARG_DOWNLOADURL: downloadURL,
      Constant.ARG_FILENAME: filename,
    };
  }

  static Future<String> addPhotoMemo(PhotoMemo photoMemo) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .add(photoMemo.serialize());
    return ref.id;
  }

  static Future<String> addPhotoComment(PhotoComment photoComment) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COMMENT)
        .add(photoComment.serialize());
    return ref.id;
  }

  static Future<String> addNotifyComment(NotificationComment notificationComment) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.NOTIFICATION_COMMENT)
        .add(notificationComment.serialize());
    return ref.id;
  }

  static Future<List<PhotoMemo>> getPhotoMemoList({@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<List<PhotoMemo>> getPhotoMemoListByNotification(
      {@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .orderBy(NotificationComment.TIMESTAMP, descending: true)
        .get();

    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<List<PhotoComment>> getPhotoCommentList(
      {@required String photoId}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COMMENT)
        .where(PhotoComment.PHOTO_ID, isEqualTo: photoId)
        .orderBy(PhotoComment.TIMESTAMP, descending: true)
        .get();

    var result = <PhotoComment>[];
    querySnapshot.docs.forEach((doc) {
      result.add(PhotoComment.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<List<NotificationComment>> getPhotoCommentNotifyListByEmail(
      {@required String ownerEmail}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.NOTIFICATION_COMMENT)
        .where(NotificationComment.OWNER_EMAIL, isEqualTo: ownerEmail)
        .orderBy(NotificationComment.TIMESTAMP, descending: true)
        .get();

    var result = <NotificationComment>[];
    querySnapshot.docs.forEach((doc) {
      result.add(NotificationComment.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<List<NotificationComment>> getPhotoCommentNotifyListByPhotoId(
      {@required String photoId}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.NOTIFICATION_COMMENT)
        .where(NotificationComment.PHOTO_ID, isEqualTo: photoId)
        .orderBy(NotificationComment.TIMESTAMP, descending: true)
        .get();

    var result = <NotificationComment>[];
    querySnapshot.docs.forEach((doc) {
      result.add(NotificationComment.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<List<dynamic>> getImageLabels({@required File photoFile}) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(photoFile);
    final ImageLabeler couldLabeler = FirebaseVision.instance.cloudImageLabeler();
    final List<ImageLabel> cloudLabels = await couldLabeler.processImage(visionImage);
    List<dynamic> labels = <dynamic>[];
    for (ImageLabel label in cloudLabels) {
      if (label.confidence >= Constant.MIN_ML_CONFIDENCE)
        labels.add(label.text.toLowerCase());
    }
    return labels;
  }

  static Future<void> updatePhotoMemo(
      String docId, Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(docId)
        .update(updateInfo);
  }

  static Future<void> updatePhotoComment(
      String docId, Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COMMENT)
        .doc(docId)
        .update(updateInfo);
  }

  static Future<List<PhotoMemo>> getPhotoMemoSharedWithMe(
      {@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.SHARED_WITH, arrayContains: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<void> deleteNotification(NotificationComment n) async {
    await FirebaseFirestore.instance
        .collection(Constant.NOTIFICATION_COMMENT)
        .doc(n.docId)
        .delete();
  }

  static Future<void> deleteComment(PhotoComment c) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COMMENT)
        .doc(c.docId)
        .delete();
  }

  static Future<void> deletePhotoMemo(PhotoMemo p) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(p.docId)
        .delete();
    await FirebaseStorage.instance.ref().child(p.photoFilename).delete();
  }

  static Future<List<PhotoMemo>> searchImage({
    @required String createdBy,
    @required List<String> searchLables,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: createdBy)
        .where(PhotoMemo.IMAGE_LABELS, arrayContainsAny: searchLables)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var results = <PhotoMemo>[];
    querySnapshot.docs
        .forEach((doc) => results.add(PhotoMemo.deserialize(doc.data(), doc.id)));
    return results;
  }
}
