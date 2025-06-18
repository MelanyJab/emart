import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/controllers/auth_controller.dart';
import 'package:emart_app/views/auth_screen/login_screen.dart';
import 'package:emart_app/views/home_screen/home.dart';
import 'package:emart_app/widgets_common/applogo_widget.dart';
import 'package:emart_app/widgets_common/bg_widget.dart';
import 'package:emart_app/widgets_common/button.dart';
import 'package:emart_app/widgets_common/custom_textfield.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool? isCheck = false;
  var controller = Get.put(AuthController());

  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var repassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return bgWidget(
        child: Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Column(
          children: [
            (context.screenHeight * 0.1).heightBox,
            applogoWidget(),
            10.heightBox,
            "Join $appname".text.fontFamily(bold).white.size(15).make(),
            15.heightBox,
            Obx(() =>
              Column(
                children: [
                  customTextField(
                      hint: nameHint,
                      title: name,
                      controller: nameController,
                      isPass: false),
                  customTextField(
                      hint: emailHint,
                      title: email,
                      controller: emailController,
                      isPass: false),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () {},
                        child: "use phone number instead".text.blue400.make()),
                  ),
                  customTextField(
                      hint: passwordHint,
                      title: password,
                      controller: passwordController,
                      isPass: true),
                  Align(
                    alignment: Alignment.centerRight,
                    child:
                        "use 4 or more characters".text.color(Colors.grey).make(),
                  ),
                  customTextField(
                      hint: passwordHint,
                      title: repass,
                      controller: repassController,
                      isPass: true),
                  10.heightBox,
                  Row(
                    children: [
                      Checkbox(
                          activeColor: redColor,
                          checkColor: whiteColor,
                          value: isCheck,
                          onChanged: (newValue) {
                            setState(() {
                              isCheck = newValue;
                            });
                          }),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style:
                                TextStyle(color: fontGrey, fontFamily: regular),
                            children: [
                              TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: termsandcond,
                                style: TextStyle(
                                  color: redColor,
                                ),
                              ),
                              TextSpan(text: ' & '),
                              TextSpan(
                                text: privpol,
                                style: TextStyle(
                                  color: redColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  10.heightBox,
                   controller.isLoading.value ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(redColor),
                 ): 
                   ourButton(
                      color: isCheck == true ? redColor : lightGrey,
                      title: signup,
                      textColor: whiteColor,
                      onPress: () async {
                        if (isCheck != false) {

                          controller.isLoading(true);
                          try {
                            final userCredential = await controller.signupMethod(
                              context: context,
                              email: emailController.text,
                              password: passwordController.text,
                            );
              
                            if (userCredential != null &&
                                userCredential.user != null) {
                              await controller.storeUserData(
                                name: nameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                              );
              
                              VxToast.show(context,
                                  msg: "Account created and logged in!");
                              Get.offAll(() => const Home());
                            } else {
                              VxToast.show(context,
                                  msg: "Signup failed: user is null.");
                            }
                          } catch (e) {
                            await auth.signOut();
                            VxToast.show(context, msg: "Error: ${e.toString()}");
                           controller.isLoading(false);
                          }
                        }
                      }).box.width(context.screenWidth - 50).make(),
                  10.heightBox,
                  RichText(
                    text: TextSpan(
                      style:
                          const TextStyle(color: fontGrey, fontFamily: regular),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Log in',
                          style: const TextStyle(
                            color: redColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(() => const LoginScreen());
                            },
                        ),
                      ],
                    ),
                  ),
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
            ),
          ],
        ),
      ),
    ));
  }
}
