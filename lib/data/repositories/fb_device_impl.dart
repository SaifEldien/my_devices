import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';
import 'package:my_devices/core/funcs/name_from_email_func.dart';
import '../../core/core.dart';
import '../providers/local/local_db.dart';
import '../providers/remote/firebase_client.dart';
import 'device_repository.dart';

class FirebaseDeviceRepository implements IDeviceRepository {
  final FirebaseClient _fb = FirebaseClient();

  @override
  Future<List<Device>> restoreDevices() async {
    final snapshot = await _fb.firestore
        .collection('users')
        .doc(_fb.currentUserId)
        .collection('devices')
        .get();

    return snapshot.docs.map((doc) => Device.fromJson(doc.data())).toList();
  }

  @override
  Future<User> retrieveUser(String email) async {
    try {
      String uid = _fb.currentUserId!;
      DocumentSnapshot snapshot = await _fb.firestore.collection('users').doc(uid).get();
      if (!snapshot.exists || snapshot.data() == null) {
        final currentUser = _fb.auth.currentUser;
        final String uid = currentUser?.uid ?? "";
        final DateTime authCreatedAt = currentUser?.metadata.creationTime ?? DateTime.now();
        final name = getNameFromEmail(email);
        _fb.auth.currentUser?.updateDisplayName(name);
        User newUser = User(
          id: uid,
          email:  email,
          createdAt: authCreatedAt.toIso8601String(),
          name: name,
          img: 'No Image',
        );
        await _fb.firestore.collection('users').doc(uid).set(newUser.toJson());
        return newUser;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      return User.fromJson(data);
    } catch (e) {
      if (kDebugMode) print("❌ Error retrieving user: $e");
      rethrow;
    }
  }

  @override
  Future<void> syncDevices(List<Device> devices) async {
    try {
      final user = FirebaseAuth.instance.currentUser ;
      if (user == null) throw Exception("User not logged in");
      final userId = user.uid;
      final batch = _fb.firestore.batch();
      for (var device in devices) {
        final docRef = _fb.firestore
            .collection('users')
            .doc(userId)
            .collection('devices')
            .doc(device.id);
        batch.set(docRef, device.toJson(uId: userId), SetOptions(merge: true));
      }
      final userDoc = _fb.firestore.collection('users').doc(userId);
      batch.update(userDoc, {'lastBackup': DateTime.now().toIso8601String()});
      await batch.commit().timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          if (kDebugMode) print("⏳ Syncing in background (Offline mode)...");
          return;
        },
      );
      if (kDebugMode) print("✅ Devices synced successfully!");
    } catch (e) {
      if (kDebugMode) print("❌ Sync Error: $e");
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _fb.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  @override
  Future<bool> login(String email, String password) async {
    try {
      final userCredential = await _fb.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user != null;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print("❌ Firebase Login Error: ${e.code} - ${e.message}");
      if (e.toString().contains("A network error")) {
        rethrow;
      }
     return false;
    }
  }

  @override
  Future<User?> retrieveUserLocally(String email) async {
    return  (await LocalDB().retrieveUser(email));
  }

  @override
  Future<void> restPassword(String email) async {
    try {
       await _fb.auth.sendPasswordResetEmail(
        email: email,
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print("❌ Firebase Rest Password Error: ${e.code} - ${e.message}");
      throw Exception(e.code);
    }
  }
}
