import 'package:get/get.dart';

class HomeController extends GetxController {
  var currentNavIndex = 0.obs;
  var previousNavIndex = 0.obs; 

  void changeTab(int newIndex) {
    previousNavIndex.value = currentNavIndex.value;
    currentNavIndex.value = newIndex;
  }
}