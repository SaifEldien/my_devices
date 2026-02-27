import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseClient {
  static final FirebaseClient _instance = FirebaseClient._internal();

  late final FirebaseFirestore firestore;
  late final FirebaseAuth auth;

  factory FirebaseClient() => _instance;

  FirebaseClient._internal() {
    firestore = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
  String? get currentUserId => auth.currentUser?.uid;
}