import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/controllers/profile_controller.dart';
import 'package:emart_app/widgets_common/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/widgets_common/bg_widget.dart';
import 'package:get/get.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers - will be populated with user data
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Address Controllers
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isDataLoaded = false;

  String _currentImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      var controller = Get.find<ProfileController>();
      
      DocumentSnapshot userDoc = await firestore
          .collection(usersCollection)
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? currentUser!.email ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _streetController.text = userData['address']?['street'] ?? '';
          _cityController.text = userData['address']?['city'] ?? '';
          _stateController.text = userData['address']?['state'] ?? '';
          _zipController.text = userData['address']?['zip'] ?? '';
          _countryController.text = userData['address']?['country'] ?? '';
          _currentImageUrl = userData['imageUrl'] ?? '';
          _isDataLoaded = true;
        });

        // Load profile image in controller
        controller.loadProfileImage(_currentImageUrl);
      } else {
        // If no user document exists, create one with basic info
        await _createUserDocument();
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load user data: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Create user document if it doesn't exist
  Future<void> _createUserDocument() async {
    var controller = Get.find<ProfileController>();
    
    await firestore.collection(usersCollection).doc(currentUser!.uid).set({
      'name': currentUser!.displayName ?? '',
      'email': currentUser!.email ?? '',
      'phone': '',
      'imageUrl': '',
      'address': {
        'street': '',
        'city': '',
        'state': '',
        'zip': '',
        'country': '',
      },
      'id': currentUser!.uid,
    });

    setState(() {
      _emailController.text = currentUser!.email ?? '';
      _nameController.text = currentUser!.displayName ?? '';
      _isDataLoaded = true;
    });

    // Load empty profile image in controller
    controller.loadProfileImage('');
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<ProfileController>();
    return bgWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
   
    // Fallback to Flutter navigation
   if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    // Final fallback
    else {
      Navigator.of(context, rootNavigator: true).pop();
    }
  },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: "Edit Profile".text.fontFamily(bold).white.size(18).make(),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : "Save".text.white.fontFamily(bold).make(),
            ),
          ],
        ),
        body: !_isDataLoaded
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Profile Picture Section
                      Obx(() {
                        return Column(
                          children: [
                            // Display current profile image
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: ClipOval(
                                child: _buildProfileImage(controller),
                              ),
                            ),
                            10.heightBox,
                            ourButton(
                              color: redColor,
                              onPress: () {
                                controller.changeImage(context);
                              },
                              textColor: whiteColor,
                              title: "Change Image",
                            ),
                          ],
                        );
                      }),

                      30.heightBox,

                      // Personal Information Section
                      _buildSectionCard(
                        title: "Personal Information",
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: "Full Name",
                            icon: Icons.person,
                          ),
                          15.heightBox,
                          _buildTextField(
                            controller: _emailController,
                            label: "Email",
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            enabled: false, // Email shouldn't be editable
                          ),
                          15.heightBox,
                          _buildTextField(
                            controller: _phoneController,
                            label: "Phone Number",
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),

                      20.heightBox,

                      // Password Section
                      _buildSectionCard(
                        title: "Change Password",
                        children: [
                          _buildPasswordField(
                            controller: _oldPasswordController,
                            label: "Current Password",
                            isObscure: _obscureOldPassword,
                            onToggle: () => setState(() =>
                                _obscureOldPassword = !_obscureOldPassword),
                          ),
                          15.heightBox,
                          _buildPasswordField(
                            controller: _newPasswordController,
                            label: "New Password",
                            isObscure: _obscureNewPassword,
                            onToggle: () => setState(() =>
                                _obscureNewPassword = !_obscureNewPassword),
                          ),
                          15.heightBox,
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            label: "Confirm New Password",
                            isObscure: _obscureConfirmPassword,
                            onToggle: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                          ),
                        ],
                      ),

                      20.heightBox,

                      // Address Section
                      _buildSectionCard(
                        title: "Address Information",
                        children: [
                          _buildTextField(
                            controller: _streetController,
                            label: "Street Address",
                            icon: Icons.home,
                          ),
                          15.heightBox,
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  controller: _cityController,
                                  label: "City",
                                  icon: Icons.location_city,
                                ),
                              ),
                              10.widthBox,
                              Expanded(
                                child: _buildTextField(
                                  controller: _stateController,
                                  label: "State",
                                  icon: Icons.map,
                                ),
                              ),
                            ],
                          ),
                          15.heightBox,
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _zipController,
                                  label: "ZIP Code",
                                  icon: Icons.local_post_office,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              10.widthBox,
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  controller: _countryController,
                                  label: "Country",
                                  icon: Icons.public,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      40.heightBox,

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: redColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                )
                              : "Save Changes"
                                  .text
                                  .white
                                  .fontFamily(bold)
                                  .size(16)
                                  .make(),
                        ),
                      ),

                      20.heightBox,
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Helper method to build profile image widget
  Widget _buildProfileImage(ProfileController controller) {
    // If a new image is selected locally
    if (controller.profileImgPath.value.isNotEmpty) {
      return Image.file(
        File(controller.profileImgPath.value),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
    // If there's an existing image URL
    else if (controller.profileImgUrl.value.isNotEmpty) {
      return Image.network(
        controller.profileImgUrl.value,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            imgProfile2,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          );
        },
      );
    }
    // Default placeholder image
    else {
      return Image.asset(
        imgProfile2,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title.text.fontFamily(bold).color(darkFontGrey).size(16).make(),
          20.heightBox,
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: redColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
      ),
      validator: (value) {
        if (label == "Full Name" && (value == null || value.isEmpty)) {
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            isObscure ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[600],
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: redColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (label.contains('New Password') &&
            value != null &&
            value.isNotEmpty &&
            value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        if (label.contains('Confirm') && value != _newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Future<void> _changePassword() async {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      return;
    }

    try {
      // Re-authenticate user with current password
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: _oldPasswordController.text,
      );

      await currentUser!.reauthenticateWithCredential(credential);

      // Update password
      await currentUser!.updatePassword(_newPasswordController.text);

      Get.snackbar(
        "Success",
        "Password updated successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to change password. Please check your current password.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var controller = Get.find<ProfileController>();
      
      // Upload image if a new one was selected
      String? imageUrl = await controller.uploadProfileImage();

      // Change password if provided
      if (_newPasswordController.text.isNotEmpty) {
        await _changePassword();
      }

      // Update Firestore document
      await firestore.collection(usersCollection).doc(currentUser!.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'imageUrl': imageUrl ?? _currentImageUrl,
        'address': {
          'street': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'zip': _zipController.text.trim(),
          'country': _countryController.text.trim(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear the selected local image path after successful save
      controller.clearImage();
      
      Get.snackbar(
        "Success",
        "Profile updated successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Navigator.pop(context);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update profile: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}