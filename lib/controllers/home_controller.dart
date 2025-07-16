import 'package:emart_app/controllers/admin_controller.dart';
import 'package:emart_app/models/category_model.dart';
import 'package:emart_app/models/product_model.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var currentNavIndex = 0.obs;
  var previousNavIndex = 0.obs;
  
  final AdminController _adminController = Get.find();

  // Products
  var featuredProducts = <ProductModel>[].obs;
  var todayDeals = <ProductModel>[].obs;
  var flashSales = <ProductModel>[].obs;
  var topSellers = <ProductModel>[].obs;
  var topCategories = <ProductModel>[].obs;
  
  // Categories
  var categories = <CategoryModel>[].obs;
  var featuredCategories = <CategoryModel>[].obs;

  @override
  void onInit() {
    fetchAllData();
    super.onInit();
  }

  Future<void> fetchAllData() async {
    try {
    // Debug print to check data
    print('Fetching top sellers...');
    topSellers.value = await _adminController.getTopSellers();
    print('Top sellers fetched: ${topSellers.length} items');
  } catch (e) {
    Get.snackbar('Error', 'Failed to load home screen data: ${e.toString()}');
  }
    try {
      // Fetch products
      featuredProducts.value = await _adminController.getFeaturedProducts();
      todayDeals.value = await _adminController.getTodayDeals();
      flashSales.value = await _adminController.getFlashSales();
      topSellers.value = await _adminController.getTopSellers();
      topCategories.value = await _adminController.getTopCategories();
      
      // Fetch categories
      categories.value = await _adminController.getAllCategories();
      featuredCategories.value = categories.take(6).toList(); // First 6 as featured
    } catch (e) {
      Get.snackbar('Error', 'Failed to load home screen data: ${e.toString()}');
    }
  }

  void changeTab(int newIndex) {
    previousNavIndex.value = currentNavIndex.value;
    currentNavIndex.value = newIndex;
  }
}