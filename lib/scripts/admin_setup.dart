// lib/utilities/admin_setup.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/consts.dart';

Future<void> setupInitialAdmin() async {
  const adminEmail = "your_admin_email@example.com"; // Replace with your actual admin email
  
  await firestore.collection('admins').doc(adminEmail).set({
    'email': adminEmail,
    'name': 'Admin User',
    'createdAt': FieldValue.serverTimestamp(),
  });
  
  print('Admin $adminEmail has been set up');
}

