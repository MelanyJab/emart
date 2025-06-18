import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:emart_app/consts/consts.dart';

class ProfileController extends GetxController {
  var profileImgPath = ''.obs;
  var profileImgUrl = ''.obs;
  var isLoading = false.obs;

  Future<void> changeImage(BuildContext context) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      
      if (image == null) return;
      
      if (kIsWeb) {
     
        final bytes = await image.readAsBytes();
        profileImgPath.value = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else {
        profileImgPath.value = image.path;
      }
    } on PlatformException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
  }

  // Upload image to Firebase Storage
  Future<String?> uploadProfileImage() async {
    if (profileImgPath.value.isEmpty) return null;

    try {
      isLoading.value = true;
      
      String fileName = 'profile_${currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}';
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$fileName.jpg');

      if (kIsWeb) {
        // For web, upload from base64 data URL
        if (profileImgPath.value.startsWith('data:image')) {
          final metadata = SettableMetadata(contentType: 'image/jpeg');
          final data = base64Decode(profileImgPath.value.split(',').last);
          final uploadTask = storageRef.putData(data, metadata);
          TaskSnapshot taskSnapshot = await uploadTask;
          String downloadUrl = await taskSnapshot.ref.getDownloadURL();
          return downloadUrl;
        } else {
          // Fallback for web if not a data URL
          return profileImgPath.value;
        }
      } else {
        // For mobile, upload from file path
        UploadTask uploadTask = storageRef.putFile(File(profileImgPath.value));
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        return downloadUrl;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Load profile image URL
  void loadProfileImage(String imageUrl) {
    profileImgUrl.value = imageUrl;
    profileImgPath.value = imageUrl; 
  }

  // Clear selected image
  void clearImage() {
    profileImgPath.value = '';
  }
}