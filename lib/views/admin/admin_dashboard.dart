// views/admin/admin_dashboard.dart
import 'package:emart_app/consts/colors.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/views/admin/admin_log_screen.dart';
import 'package:emart_app/views/admin/products/products_table.dart';
import 'package:flutter/material.dart';
import 'package:emart_app/views/admin/users/users_table.dart';
import 'package:emart_app/views/admin/categories/categories_table.dart';
import 'package:emart_app/controllers/auth_controller.dart';
import 'package:get/get.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

 static final List<Widget> _widgetOptions = <Widget>[
  const UsersTable(),
  ProductsTable(),
  CategoriesTable(),
];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: "Admin Dashboard".text.make(),
        backgroundColor: redColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.find<AuthController>().signoutMethod(context);
              Get.offAll(() => const AdminLoginScreen());
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: redColor,
        onTap: _onItemTapped,
      ),
    );
  }
}