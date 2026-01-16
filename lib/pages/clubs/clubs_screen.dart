import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../../services/mock_data_service.dart';
import '../../models/models.dart';
import '../../utils/theme.dart';
import '../../routes/app_routes.dart';
import '../../services/navigation_controller.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/inline_search_results.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  bool _isMapView = false;
  List<String> _selectedCategories = ['All'];
  final List<String> _categories = ['All', 'Electronic', 'Hip Hop', 'House'];
  final MockDataService _mockDataService = MockDataService();
  final NavigationController navCtrl = Get.find<NavigationController>();
  int _visibleNearYouCount = 3;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  late MapController _mapController;
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _mapController = MapController.withUserPosition(
      trackUserLocation: const UserTrackingOption(
        enableTracking: true,
        unFollowUser: false,
      ),
    );
    _dataFuture = _loadData();
  }

  Future<List<dynamic>> _loadData() {
    return Future.wait([
      _mockDataService.getClubs(),
      _mockDataService.getPromotions(),
    ]);
  }

  @override
  void dispose() {
    _mapController.dispose();
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
    return Obx(() {
      if (navCtrl.isClubMapView) {
        _isMapView = true;
        Future.microtask(() => navCtrl.resetClubMapView());
      }

      return GestureDetector(
        onTap: _clearSearch,
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          body: SafeArea(
            child: FutureBuilder<List<dynamic>>(
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

                return Stack(
                  children: [
                    Column(
                      children: [
                        _buildTopBar(),
                        Expanded(
                          child: _isMapView
                              ? _buildMapView(clubs, promos)
                              : _buildListView(clubs, promos),
                        ),
                      ],
                    ),
                    if (_searchQuery.isNotEmpty)
                      Positioned(
                        top: 80,
                        left: 0,
                        right: 0,
                        child: FutureBuilder<List<String>>(
                          future: _mockDataService.getAllClubCategories(),
                          builder: (context, catSnapshot) {
                            return InlineSearchResults(
                              query: _searchQuery,
                              searchType: SearchType.clubs,
                              initialCategories: catSnapshot.data ?? [],
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
            backgroundColor: AppTheme.primaryPurple,
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            label: Text(_isMapView ? 'List View' : 'Map View'),
          ),
        ),
      );
    });
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomSearchBar(
        controller: _searchController,
        hintText: 'Search for clubs...',
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildListView(List<Club> clubs, List<Promotion> promos) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      color: AppTheme.primaryPurple,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification &&
              notification.dragDetails != null) {
            _clearSearch();
          }
          return false;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryFilters(),
              _buildPromotionsCarousel(promos, clubs),
              _buildByCategorySection(clubs),
              _buildNearYouSection(clubs),
              const SizedBox(height: 80), // Added spacing to avoid overlap with FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapView(List<Club> clubs, List<Promotion> promos) {
    return Stack(
      children: [
        OSMFlutter(
          controller: _mapController,
          onGeoPointClicked: (geoPoint) {
            final club = clubs.firstWhere(
              (c) =>
                  (c.latitude - geoPoint.latitude).abs() < 0.0001 &&
                  (c.longitude - geoPoint.longitude).abs() < 0.0001,
              orElse: () => clubs.first, // Fallback (should not happen)
            );
            Get.toNamed(AppRoutes.clubDetailPath(club.id), arguments: club);
          },
          osmOption: OSMOption(
            userTrackingOption: const UserTrackingOption(
              enableTracking: true,
              unFollowUser: false,
            ),
            zoomOption: const ZoomOption(
              initZoom: 14,
              minZoomLevel: 3,
              maxZoomLevel: 19,
              stepZoom: 1.0,
            ),
            userLocationMarker: UserLocationMaker(
              personMarker: const MarkerIcon(
                iconWidget: Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 48,
                ),
              ),
              directionArrowMarker: const MarkerIcon(
                iconWidget: Icon(
                  Icons.navigation,
                  color: Colors.blue,
                  size: 48,
                ),
              ),
            ),
          ),
          onMapIsReady: (isReady) async {
            if (isReady) {
              for (int i = 0; i < clubs.length; i++) {
                final club = clubs[i];
                await _mapController.addMarker(
                  GeoPoint(
                    latitude: club.latitude,
                    longitude: club.longitude,
                  ),
                  markerIcon: MarkerIcon(
                    iconWidget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppTheme.primaryPurple, width: 1),
                          ),
                          child: Text(
                            club.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (i == 0)
                          _buildAlert(
                            'Tickets are running out!',
                            Icons.local_activity,
                            Colors.orange,
                          ),
                        if (i == 1)
                          _buildAlert(
                            'Your friends are going',
                            Icons.people,
                            AppTheme.primaryPurple,
                          ),
                        const Icon(
                          Icons.location_on,
                          color: AppTheme.primaryPurple,
                          size: 160, // Further increased size based on feedback
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
          },
        ),
        Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.black45,
              child: const Text(
                'Using your current location',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Container(
              height: 250,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppTheme.darkBackground],
                ),
              ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildPromotionsCarousel(promos, clubs),
                    _buildNearYouSection(clubs),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    final sortedCategories = List<String>.from(_categories);
    sortedCategories.sort((a, b) {
      if (a == 'All') return -1;
      if (b == 'All') return 1;
      bool aSelected = _selectedCategories.contains(a);
      bool bSelected = _selectedCategories.contains(b);
      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return 0;
    });

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sortedCategories.length,
        itemBuilder: (context, index) {
          final category = sortedCategories[index];
          final isSelected = _selectedCategories.contains(category);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            key: ValueKey(category),
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (category == 'All') {
                    _selectedCategories = ['All'];
                  } else {
                    _selectedCategories.remove('All');
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                      if (_selectedCategories.isEmpty) {
                        _selectedCategories = ['All'];
                      }
                    }
                  }
                });
              },
              selectedColor: AppTheme.primaryPurple,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromotionsCarousel(List<Promotion> promos, List<Club> clubs) {
    if (promos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'Promotions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: promos.length,
            itemBuilder: (context, index) {
              final promo = promos[index];
              return InkWell(
                onTap: () {
                  if (promo.clubId != null) {
                    Get.toNamed(AppRoutes.clubDetailPath(promo.clubId!),
                        arguments: promo.clubId);
                  }
                },
                child: Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
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
                        child:
                            Icon(Icons.percent, color: Colors.white, size: 20),
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
                          bottom: 12,
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildByCategorySection(List<Club> clubs) {
    final filteredClubs = clubs.where((c) {
      if (_selectedCategories.contains('All')) return true;
      return _selectedCategories.contains(c.category);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'By Category: ${_selectedCategories.join(", ")}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 180,
          child: filteredClubs.isEmpty
              ? const Center(
                  child: Text('No clubs found in this category',
                      style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredClubs.length,
                  itemBuilder: (context, index) {
                    final club = filteredClubs[index];
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            debugPrint('Tapped By Category Club: ${club.name}, ID: ${club.id}');
                            Get.toNamed(AppRoutes.clubDetailPath(club.id),
                                arguments: club);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: NetworkImage(club.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 12),
                                              Text(' ${club.rating}',
                                                  style: const TextStyle(
                                                      fontSize: 10)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                club.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'Near You',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: clubsToShow.length,
          itemBuilder: (context, index) {
            final club = clubsToShow[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  debugPrint('Tapped Near You Club (ClubsScreen): ${club.name}, ID: ${club.id}');
                  Get.toNamed(AppRoutes.clubDetailPath(club.id),
                      arguments: club);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(club.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    club.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 14),
                                      Text(' ${club.rating}',
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                'Downtown District • ${club.distance}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                              Text(
                                'Open until ${club.openUntil}',
                                style: TextStyle(
                                    color: AppTheme.primaryPurple
                                        .withOpacity(0.8),
                                    fontSize: 12),
                              ),
                            ],
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
        if (_visibleNearYouCount < clubs.length)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

  Widget _buildAlert(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
