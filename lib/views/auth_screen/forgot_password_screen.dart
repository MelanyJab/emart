import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/widgets_common/applogo_widget.dart';
import 'package:emart_app/widgets_common/bg_widget.dart';
import 'package:emart_app/widgets_common/button.dart';
import 'package:emart_app/widgets_common/custom_textfield.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
 @override
  Widget build(BuildContext context) {
    return bgWidget(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          children: [
            (context.screenHeight * 0.1).heightBox,
            applogoWidget(),
            10.heightBox,
            "You forgot your password!".text.fontFamily(bold).white.size(15).make(),
            15.heightBox,
            Column(
              children: [
            
                customTextField(hint: emailOrphoneHint, title: emailOrphone, isPass: false),
                
                10.heightBox,
           
              ourButton(color: redColor, title: getCode, textColor: whiteColor, onPress: (){}).box.width(context.screenWidth - 50).make(),
            
             5.heightBox,
             
            ],
            )
                .box
                .white
                .rounded
                .padding(const EdgeInsets.all(16))
                .width(context.screenWidth - 70)
                .shadowSm
                .make(),
          ],
        ),
      ),
    ));
  }
}