import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:water_intake/models/app_user.dart';
import 'package:water_intake/utils/notification_utils.dart';

class AuthProviderr extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  GoogleSignInAccount? get googleAcount => _googleSignIn.currentUser;

  User? get user => _firebaseAuth.currentUser;

  Future<bool> selectGoogleAcount() async {
    try {
      await _googleSignIn.signOut();
      GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('google_id', isEqualTo: googleAccount?.id)
          .get();
      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      if (docs.isEmpty) {
        return true;
      }
      QueryDocumentSnapshot userDoc = docs[0];
      Map<String, dynamic>? data = userDoc.data()
          as Map<String, dynamic>?; // Change the type to Map<String, dynamic>?
      TimeOfDay wakeUpTime = TimeOfDay(
        hour: data?['wake_up_time']['hour'],
        minute: data?['wake_up_time']['minute'],
      );

      await setDailyStartNotification(wakeUpTime, data?['name']);
      return false;
    } catch (e) {
      print(e);
      return true;
    }
  }

  Future<void> signIn() async {
    try {
      final currentUser = _googleSignIn.currentUser;
      if (currentUser != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await currentUser.authentication;
        OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);
        await _firebaseAuth.signInWithCredential(oAuthCredential);
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> signUp(String gender, DateTime birthday, double weight,
      TimeOfDay time, double water) async {
    try {
      await signIn();
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        DocumentReference userRef =
            _firestore.collection('users').doc(user.uid);
        await userRef.set(AppUser(
                uid: user.uid,
                googleId: _googleSignIn.currentUser!.id,
                email: user.email ?? '',
                name: user.displayName ?? '',
                gender: gender,
                birthday: birthday,
                weight: weight,
                wakeUpTime: time,
                dailyTarget: water)
            .toDoc());
        await setDailyStartNotification(time, user.displayName ?? ' ');
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  void clearGoogleAccount() async {
    await _googleSignIn.signOut();
    notifyListeners();
  }

  void signOut() async {
    await cancelAllNotifications();
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    notifyListeners();
  }
}
