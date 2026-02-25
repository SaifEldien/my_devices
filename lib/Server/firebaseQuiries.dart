// ignore_for_file: file_names
/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:my_devices/main.dart';

class FireBaseQueries {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    return;
  }

  static setToken(String email) async {
    String? token = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance.collection('users').doc(email).update({'token': token});
  }

  static Future<void> addUser(user) async {
    await FirebaseFirestore.instance.collection('users').doc(user['email']).set(user).then((value) => () {});
  }

  static Future<bool> userExist(String email) async {
    var querySnapshot = await FirebaseFirestore.instance.collection(email).doc('info').get();
    return querySnapshot.exists;
  }

  static Future retrieveUser(String email) async {
    DocumentSnapshot snapshots = await FirebaseFirestore.instance.collection(email).doc("user").get();
    var data = snapshots.data();
    return data;
  }

  static Stream retrieveFollowers(String email) {
    return FirebaseFirestore.instance
        .collection('followers')
        .where('followingEmail', isEqualTo: email)
        .snapshots();
  }

  static Stream retrieveFollowings(String email) {
    return FirebaseFirestore.instance
        .collection('followers')
        .where('followerEmail', isEqualTo: email)
        .snapshots();
  }

  static Future addFollow(String followerEmail, String followEmail) async {
    await FirebaseFirestore.instance.collection('followers').doc(followEmail + followerEmail).set({
      'followerEmail': followerEmail,
      'followingEmail': followEmail,
      'date': DateTime.now().toString(),
    });
  }

  static Future removeFollow(String followerEmail, String followEmail) async {
    await FirebaseFirestore.instance.collection('followers').doc(followEmail + followerEmail).delete();
  }

  static signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static  Future<String> singInWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      return "success";
    } catch (e) {
      if (e.toString().contains("List<Object?>' is not a subtype of type 'PigeonUserDetails?' in type cast")) return "success";
      return e.toString();
    }
  }

  static Future retrieveDevices(String userId) async {
    var devices = FirebaseFirestore.instance
        .collection(userId).doc('devices').collection('devices');

    var snapShots = await devices.get();
    var docs = snapShots.docs;
    return  List.generate(docs.length, (index) => docs[index].data());
  }

  static Stream chattedUsers(String email) {
    var data = FirebaseFirestore.instance
        .collection('Messages')
        .where(Filter.or(Filter('senderEmail', isEqualTo: email), Filter('receiverEmail', isEqualTo: email)))
        .snapshots();
    return data;
  }

  static resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return "Reset Password Link Has been sent!";
    } catch (e) {
      return e.toString();
    }
  }

  static Stream retrieveMatchingUsers(Map user) {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  static Stream retrieveMoments(String email) {
    return FirebaseFirestore.instance.collection('moments').where('userEmail', isEqualTo: email).snapshots();
  }

  static Future<void> addDevice(Map<String, dynamic> device) async {
    await FirebaseFirestore.instance
        .collection(currentUser!.id)
        .doc('devices')
        .collection('devices')
        .doc(device['id'])
        .set(device);
    return;
  }

  static addReaction(reaction) async {
    var docs = await FirebaseFirestore.instance
        .collection('reactions')
        .where('postId', isEqualTo: reaction['postId'])
        .get();
    var doseExist = docs.docs
        .where(
          (element) =>
              element.data()['postId'] == reaction['postId'] &&
              element.data()['userId'] == reaction['userId'],
        )
        .toList()
        .isNotEmpty;

    if (!doseExist) {
      await FirebaseFirestore.instance.collection('reactions').add(reaction);
    } else {
      var doc = await FirebaseFirestore.instance
          .collection('reactions')
          .where(
            Filter.and(
              Filter('postId', isEqualTo: reaction['postId']),
              (Filter('userId', isEqualTo: reaction['userId'])),
            ),
          )
          .get();
      var id = doc.docs.first.id;
      await FirebaseFirestore.instance.collection('reactions').doc(id).delete();
      if (doc.docs.first['type'] != reaction['type']) {
        await FirebaseFirestore.instance.collection('reactions').add(reaction);
      }
    }

    return;
  }

  static removeReaction(reaction) async {
    await FirebaseFirestore.instance.collection('reactions').add(reaction);
    return;
  }

  static Stream retrieveReactions(postId) {
    return FirebaseFirestore.instance.collection('reactions').where('postId', isEqualTo: postId).snapshots();
  }

  static makeMessagesSeen(List docs, email) async {
    for (int i = 0; i < docs.length; i++) {
      if (docs[i].data()['receiverEmail'] == email) {
        await FirebaseFirestore.instance.collection('Messages').doc(docs[i].id).update({'isSeen': true});
      }
    }
  }
}
*/