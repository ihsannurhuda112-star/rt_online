import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rt_online/rt_online/model/user_firebase_model.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<UserFirebaseModel> registerUser({
    required String email,
    required String username,
    required String password,
  }) async {
    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    final model = UserFirebaseModel(
      uid: user.uid,
      username: username,
      email: email,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    await firestore.collection('user').doc(user.uid).set(model.toMap());
    return model;
  }

  static Future<UserFirebaseModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final cred = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user == null) return null;

    final snap = await firestore.collection('user').doc(user.uid).get();

    if (!snap.exists) return null;

    final data = snap.data()!;

    return UserFirebaseModel.fromMap({'uid': user.uid, ...data});
  }
}
