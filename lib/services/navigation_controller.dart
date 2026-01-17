import 'package:get/get.dart';

class NavigationController extends GetxController {
  final _selectedIndex = 0.obs;
  int get selectedIndex => _selectedIndex.value;

  final _isClubMapView = false.obs;
  bool get isClubMapView => _isClubMapView.value;

  void setSelectedIndex(int index) {
    _selectedIndex.value = index;
    if (index != 1) {
      _isClubMapView.value = false;
    }
  }

  void goToClubsMap() {
    _isClubMapView.value = true;
    _selectedIndex.value = 1; // Index 1 einai Clubs
  }

  void resetClubMapView() {
    _isClubMapView.value = false;
  }
}
