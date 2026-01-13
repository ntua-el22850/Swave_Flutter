import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/navigation_controller.dart';
import 'home/home_screen.dart';
import 'clubs/clubs_screen.dart';
import 'events/events_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final NavigationController navCtrl = Get.find<NavigationController>();

  final List<Widget> _screens = [
    const HomeScreen(),
    const ClubsScreen(),
    const EventsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color purpleBackground = Color(0xFF7C5FDC);
    const Color activeColor = Colors.white; 
    const Color inactiveColor = Color(0xFFE8DFF5); 

    return Obx(() => Scaffold(
      // IndexedStack ensures bottom navigation persists and state is maintained
      body: IndexedStack(
        index: navCtrl.selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: purpleBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_bar),
                label: 'Clubs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Events',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: navCtrl.selectedIndex,
            selectedItemColor: activeColor,
            unselectedItemColor: inactiveColor,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            onTap: (index) => navCtrl.setSelectedIndex(index),
          ),
        ),
      ),
    ));
  }
}
