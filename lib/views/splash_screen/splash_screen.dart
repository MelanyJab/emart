import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/views/auth_screen/login_screen.dart';
import 'package:emart_app/views/home_screen/home.dart';
import 'package:emart_app/widgets_common/applogo_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  changeScreen() {
    Future.delayed( const Duration(seconds: 3), () {
     auth.authStateChanges().listen((User? user){
      if(user==null && mounted){
        Get.to(()=> const LoginScreen());
      }else{
        Get.to(()=>const Home());
      }
     });
    });
  }


@override
void initState(){
  changeScreen();
  super.initState();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 226, 226, 226),
    body: Center(
      child: Column(
        children: [
          Align(
              alignment: Alignment.topLeft,
              child: Image.asset(icSplashBg, width: 300)),
          20.heightBox,
          applogoWidget(),
          10.heightBox,
          appname.text.fontFamily(bold).size(22).white.make(),
          const Spacer(),
          credits.text.size(15).white.make(),
        ],
      ),
    ),
  );
}
}