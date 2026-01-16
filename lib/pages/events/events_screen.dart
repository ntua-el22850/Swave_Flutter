import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/mock_data_service.dart';
import '../../models/models.dart';
import '../../utils/theme.dart';
import '../../widgets/state_widgets.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/inline_search_results.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final MockDataService _mockDataService = MockDataService();
  List<String> _selectedCategories = ['All'];

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
      _mockDataService.getEvents(),
      _mockDataService.getClubs(),
      _mockDataService.getFriends(),
    ]);
  }

  @override
  void dispose() {
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
    // Map categories to some images for the "By Category" section
    final Map<String, String> categoryImages = {
      'Electronic': 'lib/assets/eventFilterElectronic.jpg',
      'Hip Hop': 'lib/assets/eventFilterHipHop.jpg',
      'House': 'lib/assets/eventFilterHouse.jpg',
      'Jazz': 'lib/assets/eventFilterJazz.jpg',
    };

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
                    child:
                        CircularProgressIndicator(color: AppTheme.primaryPurple));
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white)));
              }

              final allEvents = snapshot.data![0] as List<Event>;
              final clubs = snapshot.data![1] as List<Club>;
              final friends = snapshot.data![2] as List<User>;

              final filteredEvents = allEvents.where((e) {
                if (_selectedCategories.contains('All')) return true;
                return _selectedCategories.contains(e.category);
              }).toList();

              return Stack(
                children: [
                  RefreshIndicator(
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
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSearchBar(),
                              const SizedBox(height: 20),
                              _buildByCategorySection(categoryImages),
                              const SizedBox(height: 24),
                              _buildNearYouSection(filteredEvents, clubs),
                              const SizedBox(height: 24),
                              _buildFriendActivitySection(friends),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: FutureBuilder<List<String>>(
                        future: _mockDataService.getAllEventCategories(),
                        builder: (context, catSnapshot) {
                          return InlineSearchResults(
                            query: _searchQuery,
                            searchType: SearchType.events,
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
      ),
    );
  }

  Widget _buildSearchBar() {
    return CustomSearchBar(
      controller: _searchController,
      hintText: 'Search events...',
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildByCategorySection(Map<String, String> categoryImages) {
    final categoriesToShow = ['All', ...categoryImages.keys];
    final sortedCategories = List<String>.from(categoriesToShow);
    sortedCategories.sort((a, b) {
      if (a == 'All') return -1;
      if (b == 'All') return 1;
      bool aSelected = _selectedCategories.contains(a);
      bool bSelected = _selectedCategories.contains(b);
      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return 0;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'By Category',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sortedCategories.length,
            itemBuilder: (context, index) {
              final cat = sortedCategories[index];
              final isSelected = _selectedCategories.contains(cat);
              final imageUrl = cat == 'All'
                  ? 'lib/assets/eventFilterAll.jpg'
                  : categoryImages[cat]!;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                key: ValueKey(cat),
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (cat == 'All') {
                        _selectedCategories = ['All'];
                      } else {
                        _selectedCategories.remove('All');
                        if (_selectedCategories.contains(cat)) {
                          _selectedCategories.remove(cat);
                          if (_selectedCategories.isEmpty) {
                            _selectedCategories = ['All'];
                          }
                        } else {
                          _selectedCategories.add(cat);
                        }
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(color: AppTheme.primaryPurple, width: 2)
                          : null,
                      image: DecorationImage(
                        image: AssetImage(imageUrl),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(isSelected ? 0.2 : 0.5),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.bold,
                          fontSize: 16,
                        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Events',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        events.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No events found for this category',
                      style: TextStyle(color: Colors.white54)),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final club = clubs.firstWhere((c) => c.id == event.clubId,
                      orElse: () => Club(
                          id: '',
                          name: 'Unknown',
                          rating: 0,
                          category: '',
                          location: '',
                          latitude: 0,
                          longitude: 0,
                          distance: '',
                          openUntil: '',
                          imageUrl: '',
                          description: ''));

                  return _buildEventCard(event, club);
                },
              ),
      ],
    );
  }

  Widget _buildEventCard(Event event, Club club) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('Tapped Event: ${event.name}, ID: ${event.id}');
          Get.toNamed(AppRoutes.eventDetailPath(event.id), arguments: event);
        },
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
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      event.imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'EVENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${event.price.toInt()}\$',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            event.date,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.nightlife,
                            size: 16, color: AppTheme.primaryPurple),
                        const SizedBox(width: 6),
                        Text(
                          club.name,
                          style: const TextStyle(
                            color: AppTheme.primaryPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          club.distance,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people_outline,
                            size: 16, color: Colors.white54),
                        const SizedBox(width: 6),
                        Text(
                          '${event.attendees} attendees',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13),
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
  }

  Widget _buildFriendActivitySection(List<User> friends) {
    if (friends.isEmpty) return const SizedBox.shrink();
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
            const Row(
              children: [
                Icon(Icons.local_fire_department,
                    color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text(
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
                            backgroundImage:
                                NetworkImage(friends[index].avatarUrl),
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
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.white70),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
