import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var isLoading = false.obs;

  User? get currentUser => FirebaseAuth.instance.currentUser;

  // Login
  Future<UserCredential?> loginMethod({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    UserCredential? userCredential;
    try {
      userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
    return userCredential;
  }

  // Signup
  Future<UserCredential?> signupMethod({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    UserCredential? userCredential;
    try {
      userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
    return userCredential;
  }

  // Store user data
 storeUserData({
  required String name,
  required String email,
  required String password,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("User is null while storing data.");
  }

  DocumentReference store = firestore.collection(usersCollection).doc(user.uid);

  await store.set({
    'name': name,
    'email': email,
    'password': password, 
    'imageUrl': '',
    'id': currentUser!.uid,
  });
}


  // Sign out
 Future<void> signoutMethod(BuildContext context, {
  String? email,
  String? password,
}) async {
  try {
    await auth.signOut();
  } on FirebaseAuthException catch (e) {
    VxToast.show(context, msg: e.toString());
  }
}
// Admin login check
Future<bool> isAdmin(String email) async {
  final doc = await firestore.collection('admins').doc(email).get();
  return doc.exists;
}

// Admin login method
Future<UserCredential?> adminLoginMethod({
  required BuildContext context,
  required String email,
  required String password,
}) async {
  try {
    final isAdminUser = await isAdmin(email);
    if (!isAdminUser) {
      VxToast.show(context, msg: "Not authorized as admin");
      return null;
    }
    
    return await loginMethod(context: context, email: email, password: password);
  } catch (e) {
    VxToast.show(context, msg: e.toString());
    return null;
  }
}
Future<void> setupInitialAdmin(String email, String name) async {
  try {
    await firestore.collection('admins').doc(email).set({
      'email': email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    Get.snackbar('Success', 'Admin $email created');
  } catch (e) {
    Get.snackbar('Error', e.toString());
  }
}
}
