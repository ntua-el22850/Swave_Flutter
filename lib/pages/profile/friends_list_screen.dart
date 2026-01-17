import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/theme.dart';
import '../../services/auth_service.dart';
import '../../services/mongodb_service.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';
import '../../services/navigation_controller.dart';
import '../../widgets/state_widgets.dart';

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userFriendIds = (AuthService.currentUser?['friends'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MongoDBService.getUsersByIds(userFriendIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple));
          }
          final friendsJson = snapshot.data ?? [];
          final friends = friendsJson.map((json) => User.fromJson(json)).toList();

          return Column(
            children: [
              _buildGradientHeader(),
              Expanded(
                child: friends.isEmpty
                    ? const EmptyStateWidget(
                        title: 'No friends yet',
                        message: 'Start connecting with people to see them here!',
                        icon: Icons.people_outline,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                           (context as Element).markNeedsBuild();
                        },
                        color: AppTheme.primaryPurple,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            return _buildFriendRow(friends[index]);
                          },
                        ),
                      ),
              ),
            ],
          );
        }
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple,
            Colors.blue.shade800,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 10),
          const Text(
            'Your Friends',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendRow(User friend) {
    final String initial = friend.username.isNotEmpty ? friend.username[0].toUpperCase() : '?';

    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.userDetailPath(friend.id), arguments: friend),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF24243E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppTheme.primaryPurple.withOpacity(0.2),
            child: Text(
              initial,
              style: TextStyle(
                color: AppTheme.primaryPurple,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Text(
            friend.username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),);
  }

  Widget _buildBottomNav() {
    const Color purpleBackground = Color(0xFF7C5FDC);
    const Color activeColor = Colors.white;
    const Color inactiveColor = Color(0xFFE8DFF5);
    final NavigationController navCtrl = Get.find<NavigationController>();

    return Container(
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
          currentIndex: 3,
          selectedItemColor: activeColor,
          unselectedItemColor: inactiveColor,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) {
            if (index != 3) {
              navCtrl.setSelectedIndex(index);
              Get.offAllNamed(AppRoutes.main);
            }
          },
        ),
      ),
    );
  }
}
