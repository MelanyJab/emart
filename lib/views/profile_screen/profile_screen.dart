import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/controllers/auth_controller.dart';
import 'package:emart_app/controllers/profile_controller.dart';
import 'package:emart_app/views/admin/admin_log_screen.dart';
import 'package:emart_app/views/auth_screen/login_screen.dart';
import 'package:emart_app/views/cart_screen/cart_screen.dart';
import 'package:emart_app/views/profile_screen/edit_screen.dart';
import 'package:emart_app/views/profile_screen/favorite_screen.dart';
import 'package:flutter/material.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/widgets_common/bg_widget.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
   var controller = Get.put(ProfileController());
  
  // Add this to fetch stats when screen loads
  WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.fetchUserStats();
  });

    return bgWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
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
          actions: [
            IconButton(
              onPressed: () => Get.to(() => const ProfileEditScreen()),
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: 'edit',
            ),
            IconButton(
              onPressed: () async {
                await Get.put(AuthController()).signoutMethod(context);
                Get.offAll(() => const LoginScreen());
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
            ),
            if (Get.find<AuthController>().currentUser?.email != null)
              IconButton(
                onPressed: () async {
                  bool isAdmin = await Get.find<AuthController>()
                      .isAdmin(Get.find<AuthController>().currentUser!.email!);
                  if (isAdmin) {
                    Get.to(() => const AdminLoginScreen());
                  } else {
                    VxToast.show(context, msg: "Admin access only");
                  }
                },
                icon:
                    const Icon(Icons.admin_panel_settings, color: Colors.white),
                tooltip: 'Admin',
              ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: firestore
                .collection(usersCollection)
                .doc(currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Something went wrong',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Text(
                    'No user data found',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final userName = userData['name'] ?? 'User';
              final userEmail = userData['email'] ?? currentUser!.email ?? '';
              final imageUrl = userData['imageUrl'] ?? '';

              controller.loadProfileImage(imageUrl);

              return Column(
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Profile Info
                        Row(
                          children: [
                            // Profile Image
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                              ),
                              child: ClipOval(
                                child: _buildProfileImage(imageUrl),
                              ),
                            ),
                            15.widthBox,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    userEmail,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        30.heightBox,

                        // Stats Row
                        // Stats Row
                        Obx(() => Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      controller.cartCount.value.toString(),
                                      "In Cart",
                                    ).onTap(() {
                                      Get.to(() => const CartScreen());
                                    }),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildStatCard(
                                      controller.favoriteCount.value.toString(),
                                      "Favorites",
                                    ).onTap(() {
                                      Get.to(() => const FavoritesScreen());
                                    }),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildStatCard(
                                      controller.orderCount.value.toString(),
                                      "Orders",
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),

                  // Menu Items Section
                  Expanded(
                    child: Container(
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          _buildMenuItem(
                            Icons.account_balance_wallet,
                            "My Wallet",
                            onTap: () {
                              // Handle wallet tap
                            },
                          ),
                          _buildMenuItem(
                            Icons.receipt_long,
                            "My Orders",
                            onTap: () {
                              // Handle orders tap
                            },
                          ),
                          _buildMenuItem(
                            Icons.favorite,
                            "My Favorites",
                            onTap: () {
                              Get.to(() => const FavoritesScreen());
                            },
                          ),
                          _buildMenuItem(
                            Icons.star_border,
                            "Earned Points",
                            onTap: () {
                              // Handle points tap
                            },
                          ),
                          _buildMenuItem(
                            Icons.refresh,
                            "Refund Requests",
                            onTap: () {
                              // Handle refunds tap
                            },
                          ),
                          _buildMenuItem(
                            Icons.message,
                            "Messages",
                            onTap: () {
                              // Handle messages tap
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper method to build profile image widget (same logic as in ProfileEditScreen)
  Widget _buildProfileImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
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
    } else {
      // Default placeholder image
      return Image.asset(
        imgProfile2,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }

  // Method to get user statistics from Firestore
  Future<Map<String, int>> _getUserStats() async {
    try {
      String userId = currentUser!.uid;

      // Get cart count
      QuerySnapshot cartSnapshot = await firestore
          .collection('cart')
          .where('user_id', isEqualTo: userId)
          .get();

      // Get wishlist count
      QuerySnapshot wishlistSnapshot = await firestore
          .collection('wishlist')
          .where('user_id', isEqualTo: userId)
          .get();

      // Get orders count
      QuerySnapshot ordersSnapshot = await firestore
          .collection('orders')
          .where('user_id', isEqualTo: userId)
          .get();

      return {
        'cart': cartSnapshot.docs.length,
        'wishlist': wishlistSnapshot.docs.length,
        'orders': ordersSnapshot.docs.length,
      };
    } catch (e) {
      print('Error fetching user stats: $e');
      return {'cart': 0, 'wishlist': 0, 'orders': 0};
    }
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          number.text.fontFamily(bold).size(20).color(redColor).make(),
          5.heightBox,
          label.text
              .size(12)
              .color(Colors.grey[600])
              .textStyle(const TextStyle(height: 1.2))
              .make(),
        ],
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        8.heightBox,
        label.text.white.size(12).make(),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
            15.widthBox,
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: semibold,
                  color: Colors.grey[800],
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
