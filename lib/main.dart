import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/controllers/admin_controller.dart';
import 'package:emart_app/controllers/auth_controller.dart';
import 'package:emart_app/controllers/cart_controller.dart';
import 'package:emart_app/controllers/favorite_controller.dart';
import 'package:emart_app/views/splash_screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'consts/consts.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  // Initialize both controllers
  Get.put(CartController());
  Get.put(FavoriteController());
  Get.put(AuthController());
  Get.put(AdminController());
  createSpecialCategories();



  runApp(const MyApp());
}
void createSpecialCategories() async {
  final specialCategories = [
    {'name': 'Today Deals', 'id': 'today_deals', 'isSpecial': true},
    {'name': 'Flash Sales', 'id': 'flash_sales', 'isSpecial': true},
    {'name': 'Top Categories', 'id': 'top_categories', 'isSpecial': true},
    {'name': 'Brands', 'id': 'brands', 'isSpecial': true},
    {'name': 'Top Sellers', 'id': 'top_sellers', 'isSpecial': true},
  ];

  final batch = FirebaseFirestore.instance.batch();
  
  for (var category in specialCategories) {
    final docRef = FirebaseFirestore.instance.collection('categories').doc(category['id'] as String?);
    batch.set(docRef, {
      'name': category['name'],
      'isSpecial': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: appname,
      theme: ThemeData(
  scaffoldBackgroundColor: Colors.transparent,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  fontFamily: regular,
),

      home: const SplashScreen(),
    );
  }
}

