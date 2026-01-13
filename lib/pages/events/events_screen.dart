import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/mock_data_service.dart';
import '../../models/models.dart';
import '../../utils/theme.dart';
import '../../widgets/state_widgets.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final MockDataService _mockDataService = MockDataService();
  String _selectedCategory = 'All';
  bool _isListView = true;
  bool _isLoading = false;

  final List<String> _categories = ['All', 'Electronic', 'Hip Hop', 'House', 'Jazz', 'Latin'];

  @override
  void initState() {
    super.initState();
    _loadData();
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
    final events = _mockDataService.getEvents();
    final friends = _mockDataService.getFriends();
    final clubs = _mockDataService.getClubs();

    // Map categories to some images for the "By Category" section
    final Map<String, String> categoryImages = {
      'Electronic': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
      'Hip Hop': 'https://images.unsplash.com/photo-1571266028243-3716f02d2d2e',
      'House': 'https://images.unsplash.com/photo-1574391884720-bbc37bb15932',
      'Jazz': 'https://images.unsplash.com/photo-1511192336575-5a79af67a629',
    };

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? _buildShimmerLoading()
            : RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.primaryPurple,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                        const SizedBox(height: 20),
                        _buildCategoryTabs(),
                        const SizedBox(height: 20),
                        _buildViewToggle(),
                        const SizedBox(height: 20),
                        _buildByCategorySection(categoryImages),
                        const SizedBox(height: 24),
                        _buildNearYouSection(events, clubs),
                        const SizedBox(height: 24),
                        _buildFriendActivitySection(friends),
                        const SizedBox(height: 80), // Space for bottom nav
                      ],
                    ),
                  ),
                ),
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
          const ShimmerPlaceholder(width: 120, height: 32),
          const SizedBox(height: 20),
          const ShimmerPlaceholder(width: double.infinity, height: 48),
          const SizedBox(height: 20),
          Row(
            children: List.generate(
              5,
              (index) => const Padding(
                padding: EdgeInsets.only(right: 8),
                child: ShimmerPlaceholder(width: 70, height: 32, borderRadius: 20),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const ShimmerPlaceholder(width: 150, height: 24),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: ShimmerPlaceholder(width: 140, height: 100),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const ShimmerPlaceholder(width: 150, height: 24),
          const SizedBox(height: 16),
          ...List.generate(
            2,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: ShimmerPlaceholder(width: double.infinity, height: 250),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Events',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search events...',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.white70),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.tune, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: AppTheme.primaryPurple,
              backgroundColor: Colors.white.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              _buildToggleButton(Icons.list, 'List', _isListView),
              _buildToggleButton(Icons.map, 'Map', !_isListView),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(IconData icon, String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isListView = (text == 'List');
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.white70),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildByCategorySection(Map<String, String> categoryImages) {
    final categoriesToShow = categoryImages.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'By Category',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categoriesToShow.length,
            itemBuilder: (context, index) {
              final cat = categoriesToShow[index];
              return InkWell(
                onTap: () {
                  setState(() => _selectedCategory = cat);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(categoryImages[cat]!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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

  Widget _buildNearYouSection(List<Event> events, List<Club> clubs) {
    // For demo purposes, we'll just use the first few events
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Near You',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3, // Show 3 for demo
          itemBuilder: (context, index) {
            final event = events[index % events.length];
            // Find corresponding club to get location/distance/hours
            final club = clubs.firstWhere((c) => c.name == event.clubName, orElse: () => clubs[0]);
            
            return _buildEventCard(event, club);
          },
        ),
      ],
    );
  }

  Widget _buildEventCard(Event event, Club club) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.eventDetailPath(event.id), arguments: event),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              event.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.clubName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${event.price.toInt()}\$/per',
                      style: const TextStyle(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      '${club.distance} • ${club.location}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      'Doors Open At ${club.openUntil}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
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

  Widget _buildFriendActivitySection(List<User> friends) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.friendsList),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Tickets are running out!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 30,
                child: Stack(
                  children: List.generate(friends.take(4).length, (index) {
                    return Positioned(
                      left: index * 20.0,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: AppTheme.darkBackground,
                        child: CircleAvatar(
                          radius: 13,
                          backgroundImage: NetworkImage(friends[index].avatarUrl),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Expanded(
                child: Text(
                  'Your friends are going',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
