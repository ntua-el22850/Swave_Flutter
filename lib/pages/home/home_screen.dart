import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/navigation_controller.dart';
import '../../utils/theme.dart';
import '../../services/mock_data_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/inline_search_results.dart';
import '../../models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final mockData = MockDataService();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _visibleNearYouCount = 3;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<List<dynamic>> _loadData() {
    return Future.wait([
      mockData.getClubs(),
      mockData.getPromotions(),
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    if (_searchQuery.isNotEmpty || _searchController.text.isNotEmpty) {
      setState(() {
        _searchQuery = '';
        _searchController.clear();
        FocusScope.of(context).unfocus();
      });
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _clearSearch,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: SafeArea(
          child: Stack(
            children: [
              FutureBuilder<List<dynamic>>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryPurple));
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white)));
                  }

                  final clubs = snapshot.data![0] as List<Club>;
                  final promos = snapshot.data![1] as List<Promotion>;

                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollStartNotification &&
                          notification.dragDetails != null) {
                        _clearSearch();
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          _buildSearchBar(),
                          const SizedBox(height: 10),
                          _buildPromotionsSection(promos, clubs),
                          const SizedBox(height: 24),
                          _buildPreviouslyVisitedSection(
                              clubs.take(3).toList()),
                          const SizedBox(height: 24),
                          _buildNearYouSection(clubs),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (_searchQuery.isNotEmpty)
                Positioned(
                  top: 130, 
                  left: 0,
                  right: 0,
                  child: FutureBuilder<List<String>>(
                    future: mockData.getAllCategories(),
                    builder: (context, snapshot) {
                      return InlineSearchResults(
                        query: _searchQuery,
                        searchType: SearchType.all,
                        initialCategories: snapshot.data ?? [],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Center(
        child: Column(
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.waves, color: AppTheme.primaryPurple, size: 32),
                SizedBox(width: 8),
                Text(
                  'SWAVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const Text(
              'nightclub bookings • events',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: CustomSearchBar(
        controller: _searchController,
        hintText: 'Search for clubs, events...',
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildPromotionsSection(List<Promotion> promos, List<Club> clubs) {
    if (promos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: Text(
            'Promotions!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: promos.length,
                itemBuilder: (context, index) {
                  final promo = promos[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: InkWell(
                      onTap: () {
                        if (promo.clubId != null) {
                          Get.toNamed(AppRoutes.clubDetailPath(promo.clubId!),
                              arguments: promo.clubId);
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(promo.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.7)
                                  ],
                                ),
                              ),
                            ),
                            if (promo.isNew)
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('NEW',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                              ),
                            const Positioned(
                              top: 12,
                              right: 12,
                              child: Icon(Icons.percent,
                                  color: Colors.white, size: 20),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    promo.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    promo.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            if (promo.clubId != null)
                              Positioned(
                                bottom: 45,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    clubs
                                        .firstWhere((c) => c.id == promo.clubId,
                                            orElse: () => Club(
                                                id: '',
                                                name: 'Club',
                                                rating: 0,
                                                category: '',
                                                location: '',
                                                latitude: 0,
                                                longitude: 0,
                                                distance: '',
                                                openUntil: '',
                                                imageUrl: '',
                                                description: ''))
                                        .name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 30,
              child: _buildCarouselArrow(
                icon: Icons.arrow_back_ios,
                onTap: () {
                  if (_pageController.page?.round() == 0) {
                    _pageController.animateToPage(
                      promos.length - 1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
            Positioned(
              right: 30,
              child: _buildCarouselArrow(
                icon: Icons.arrow_forward_ios,
                onTap: () {
                  if (_pageController.page?.round() == promos.length - 1) {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              promos.length,
              (index) => Container(
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppTheme.primaryPurple
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
        ),
      ],
    );
  }

  Widget _buildCarouselArrow(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildPreviouslyVisitedSection(List<Club> clubs) {
    if (clubs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Previously Visited',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Get.toNamed(AppRoutes.bookingsHistory),
                icon: const Icon(Icons.arrow_forward,
                    color: Colors.white70, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    debugPrint('Tapped Previously Visited Club: ${club.name}, ID: ${club.id}');
                    Get.toNamed(AppRoutes.clubDetailPath(club.id),
                        arguments: club.id);
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF24243E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(club.imageUrl),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                  color: AppTheme.primaryPurple.withOpacity(0.2),
                                  width: 3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          club.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.orange, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${club.rating}',
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPurple,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                club.category,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNearYouSection(List<Club> clubs) {
    final clubsToShow = clubs.take(_visibleNearYouCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on,
                          color: AppTheme.primaryPurple, size: 22),
                      SizedBox(width: 6),
                      Text(
                        'Near You',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Get.find<NavigationController>().goToClubsMap();
                    },
                    icon: const Icon(Icons.arrow_forward,
                        color: Colors.white70, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Padding(
                padding: EdgeInsets.only(left: 28.0),
                child: Text(
                  'Downtown District',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: clubsToShow.length,
          itemBuilder: (context, index) {
            final club = clubsToShow[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  debugPrint('Tapped Near You Club: ${club.name}, ID: ${club.id}');
                  Get.toNamed(AppRoutes.clubDetailPath(club.id),
                      arguments: club.id);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24243E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'club_img_${club.id}',
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(club.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              club.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.orange, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${club.rating}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.directions_walk,
                                    color: Colors.white54, size: 14),
                                Text(
                                  ' ${club.distance}',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: AppTheme.primaryPurple, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Open until ${club.openUntil}',
                                  style: TextStyle(
                                    color:
                                        AppTheme.primaryPurple.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
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
              ),
            );
          },
        ),
        if (_visibleNearYouCount < clubs.length)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _visibleNearYouCount += 3;
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Load More',
                  style: TextStyle(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
