import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../../services/mock_data_service.dart';
import '../../models/models.dart';
import '../../utils/theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/state_widgets.dart';
import '../../services/navigation_controller.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  bool _isMapView = false;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Electronic', 'Hip Hop', 'House'];
  final MockDataService _mockDataService = MockDataService();
  bool _isSatellite = false;
  bool _isLoading = false;
  final NavigationController navCtrl = Get.find<NavigationController>();
  int _visibleNearYouCount = 3;

  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController.withUserPosition(
      trackUserLocation: const UserTrackingOption(
        enableTracking: true,
        unFollowUser: false,
      ),
    );
    _loadData();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Mock loading delay
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (navCtrl.isClubMapView) {
        _isMapView = true;
        // Reset the flag immediately so user can still toggle manually
        Future.microtask(() => navCtrl.resetClubMapView());
      }

      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: _isMapView ? _buildMapView() : _buildListView(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Hinted search text',
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isMapView ? Icons.format_list_bulleted : Icons.map_outlined,
                      color: Colors.white70,
                    ),
                    onPressed: () => setState(() => _isMapView = !_isMapView),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.primaryPurple,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryFilters(),
            _buildPromotionsCarousel(),
            _buildByCategorySection(),
            _buildNearYouSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ShimmerPlaceholder(width: 80, height: 32, borderRadius: 20),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const ShimmerPlaceholder(width: 150, height: 24),
          const SizedBox(height: 16),
          const ShimmerPlaceholder(width: double.infinity, height: 160),
          const SizedBox(height: 32),
          const ShimmerPlaceholder(width: 200, height: 24),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.only(right: 16),
                child: ShimmerPlaceholder(width: 140, height: 180),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    final clubs = _mockDataService.getClubs();

    return Stack(
      children: [
        OSMFlutter(
          controller: _mapController,
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
                icon: Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 48,
                ),
              ),
              directionArrowMarker: const MarkerIcon(
                icon: Icon(
                  Icons.navigation,
                  color: Colors.blue,
                  size: 48,
                ),
              ),
            ),
            staticPoints: [
              StaticPositionGeoPoint(
                "clubs",
                MarkerIcon(
                  icon: Icon(
                    Icons.location_on,
                    color: AppTheme.primaryPurple,
                    size: 48,
                  ),
                ),
                clubs.map((c) => GeoPoint(latitude: 51.5 + (clubs.indexOf(c) * 0.01), longitude: -0.12 + (clubs.indexOf(c) * 0.01))).toList(),
              ),
            ],
          ),
          onMapIsReady: (isReady) async {
            if (isReady) {
              // In a real app, we'd add markers here with specific icons/stickers
              // For this implementation, we'll use the staticPoints above
            }
          },
        ),
        // Club Markers with stickers
        ...clubs.map((club) {
          // This is a simplified way to show stickers near markers in a Stack
          // In a production app with OSM, you'd use custom markers or overlays
          int index = clubs.indexOf(club);
          return Positioned(
            top: 150 + (index * 50.0),
            left: 100 + (index * 30.0),
            child: Column(
              children: [
                if (index == 0) _buildAlert('Tickets are running out!', Icons.local_activity, Colors.orange),
                if (index == 1) _buildAlert('Your friends are going', Icons.people, AppTheme.primaryPurple),
                Icon(Icons.location_on, color: AppTheme.primaryPurple, size: 40),
              ],
            ),
          );
        }),
        
        // Map Overlays
        Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.black45,
              child: const Text(
                'Using your current location',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            // Bottom sections in Map View
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
                physics: const NeverScrollableScrollPhysics(), // Just a peek
                child: Column(
                  children: [
                    _buildPromotionsCarousel(),
                    _buildNearYouSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapPin() {
    return const Icon(Icons.location_on, color: AppTheme.primaryPurple, size: 40);
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
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

  Widget _buildPromotionsCarousel() {
    final promos = _mockDataService.getPromotions();
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
              return Container(
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
                          colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.7)],
                        ),
                      ),
                    ),
                    if (promo.isNew)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('NEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: Icon(Icons.percent, color: Colors.white, size: 20),
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            promo.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildByCategorySection() {
    final clubs = _mockDataService.getClubs().where((c) => 
      _selectedCategory == 'All' || c.category == _selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'By Category: $_selectedCategory',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 180,
              child: clubs.isEmpty
                  ? const Center(child: Text('No clubs found in this category', style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: clubs.length,
                      itemBuilder: (context, index) {
                        final club = clubs[index];
                        return InkWell(
                          onTap: () => Get.toNamed(AppRoutes.clubDetailPath(club.id), arguments: club),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 16),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 12),
                                      Text(' ${club.rating}', style: const TextStyle(fontSize: 10)),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  void _loadMoreNearYou() {
    setState(() {
      _visibleNearYouCount += 3;
    });
  }

  Widget _buildNearYouSection() {
    final allClubs = _mockDataService.getClubs();
    final clubs = allClubs.take(_visibleNearYouCount).toList();

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
          itemCount: clubs.length,
          itemBuilder: (context, index) {
            final club = clubs[index];
            return InkWell(
              onTap: () => Get.toNamed(AppRoutes.clubDetailPath(club.id), arguments: club),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  club.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                    Text(' ${club.rating}', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              'Downtown District • ${club.distance}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              'Open until 4:00 AM',
                              style: TextStyle(color: AppTheme.primaryPurple.withOpacity(0.8), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (_visibleNearYouCount < allClubs.length)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _loadMoreNearYou,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Load More',
                  style: TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold),
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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
