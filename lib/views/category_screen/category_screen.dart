import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/views/category_screen/category_details_screen.dart';
import 'package:emart_app/widgets_common/bg_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required String title, required String categoryId});

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
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
  icon: Icon(Icons.arrow_back),
),
          title: "Categories"
              .text
              .fontFamily(bold)
              .white
              .size(25)
              .make(),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
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
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: 200,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryData = category.data() as Map<String, dynamic>;
                
                return Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: categoryData['imageUrl'] != null
                            ? Image.network(
                                categoryData['imageUrl'],
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/s1.jpg',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    10.heightBox,
                    Text(
                      categoryData['name'] ?? 'Unnamed Category',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkFontGrey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
                .box
                .white
                .rounded
                .padding(const EdgeInsets.all(8))
                .shadowSm
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
      ),
    );
  }
}