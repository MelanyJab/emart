import 'package:emart_app/controllers/auth_controller.dart';
import 'package:emart_app/views/admin/admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:get/get.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              "Admin Login".text.fontFamily(bold).size(24).color(darkFontGrey).make(),
              30.heightBox,
              TextFormField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              10.heightBox,
              TextFormField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              20.heightBox,
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: redColor,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () async {
                    controller.isLoading(true);
                    await controller.adminLoginMethod(
                      context: context,
                      email: controller.emailController.text.trim(),
                      password: controller.passwordController.text.trim(),
                    ).then((value) {
                      if (value != null) {
                        Get.offAll(() => const AdminDashboard());
                      }
                    });
                    controller.isLoading(false);
                  },
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
                      : "Login".text.white.fontFamily(bold).make(),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}