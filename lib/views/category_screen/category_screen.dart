import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/models/category_model.dart';
import 'package:emart_app/views/category_screen/category_details_screen.dart';
import 'package:emart_app/widgets_common/bg_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: "Categories"
              .text
              .fontFamily(bold)
              .white
              .size(25)
              .make(),
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              (context.screenHeight * 0.1).heightBox,
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading categories'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data!.docs;

                  return GridView.builder(
                    itemCount: categories.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 200,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final categoryData = category.data() as Map<String, dynamic>;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/s1.jpg',
                            height: 120,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                          20.heightBox,
                          Text(
                            categoryData['name'] ?? 'Unnamed Category',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: darkFontGrey),
                          ),
                        ],
                      )
                      .box
                      .white
                      .rounded
                      .clip(Clip.antiAlias)
                      .outerShadowSm
                      .make()
                      .onTap(() {
                        Get.to(() => CategoryDetailsScreen(
                          categoryId: category.id,
                          title: categoryData['name'],
                        ));
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}