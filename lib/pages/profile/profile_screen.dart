import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/theme.dart';
import '../../services/mock_data_service.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/mongodb_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockService = MockDataService();
    final userFavoritesIds = (AuthService.currentUser?['favoriteClubs'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: Future.wait([
            mockService.getClubs(),
            mockService.getVisitedClubs(),
            MongoDBService.getClubsByIds(userFavoritesIds),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            }

            final allClubs = snapshot.data![0] as List<Club>;
            final visitedClubs = snapshot.data![1] as List<Club>;
            final favoriteClubsJson = snapshot.data![2] as List<Map<String, dynamic>>;
            final favorites = favoriteClubsJson.map((json) => Club.fromJson(json)).toList();
            
            final recommended = allClubs.where((c) => !userFavoritesIds.contains(c.id)).take(4).toList();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildActionGrid(),
                    const SizedBox(height: 30),
                    _buildHorizontalSection('Favorites', favorites),
                    const SizedBox(height: 30),
                    _buildHorizontalSection('Recently Visited', visitedClubs),
                    const SizedBox(height: 30),
                    _buildHorizontalSection('Clubs You Might Like', recommended),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final username = AuthService.currentUser?['username'] ?? 'User';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $username',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Ready for tonight?',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white54),
          onPressed: () {
            AuthService.logout();
            Get.offAllNamed(AppRoutes.login);
          },
        ),
      ],
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 2.5,
      children: [
        _buildActionButton('Your Account', Icons.person_outline, () async {
          final currentUserData = AuthService.currentUser;
          if (currentUserData != null) {
            Get.toNamed(AppRoutes.userDetail, arguments: User.fromJson(currentUserData));
          }
        }),
        _buildActionButton('Friends', Icons.people_outline, () {
          Get.toNamed(AppRoutes.friendsList);
        }),
        _buildActionButton('Settings', Icons.settings_outlined, () {
          Get.toNamed(AppRoutes.settings);
        }),
        _buildActionButton('Bookings', Icons.calendar_today_outlined, () {
          Get.toNamed(AppRoutes.bookingsHistory);
        }),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF24243E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryPurple, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalSection(String title, List<Club> clubs) {
    if (clubs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: clubs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              return _buildClubCard(clubs[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClubCard(Club club) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.clubDetail, arguments: club),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF24243E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                club.imageUrl,
                height: 110,
                width: 160,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            club.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          club.category,
                          style: TextStyle(
                            color: AppTheme.primaryPurple,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
