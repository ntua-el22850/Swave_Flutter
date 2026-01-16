import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/models.dart';
import '../../services/mock_data_service.dart';
import '../../utils/theme.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Event? event;
  final MockDataService _mockDataService = MockDataService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    debugPrint('EventDetailScreen: _loadEvent called. Arguments: ${Get.arguments}');
    setState(() => _isLoading = true);
    try {
      if (Get.arguments is Event) {
        event = Get.arguments as Event;
        debugPrint('EventDetailScreen: Loaded event from arguments: ${event?.name}');
      } else {
        final String? id = Get.parameters['id'];
        debugPrint('EventDetailScreen: No Event argument, trying ID from parameters: $id');
        if (id != null) {
          final List<Event> allEvents = await _mockDataService.getEvents();
          try {
            event = allEvents.firstWhere((e) => e.id == id);
            debugPrint('EventDetailScreen: Loaded event from ID $id: ${event?.name}');
          } catch (e) {
            debugPrint('EventDetailScreen: Event ID $id not found, falling back');
            event = allEvents.isNotEmpty ? allEvents.first : null;
          }
        } else {
          final List<Event> allEvents = await _mockDataService.getEvents();
          event = allEvents.isNotEmpty ? allEvents.first : null;
        }
      }
    } catch (e) {
      debugPrint('Error loading event: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryPurple),
        ),
      );
    }

    final currentEvent = event;
    if (currentEvent == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
          child: Text(
            'Event not found',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                currentEvent.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currentEvent.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${currentEvent.price.toInt()}\$',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<Club?>(
                    future: _mockDataService.getClubById(currentEvent.clubId),
                    builder: (context, snapshot) {
                      final clubName = snapshot.data?.name ?? 'Loading...';
                      return Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppTheme.primaryPurple, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            clubName,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppTheme.primaryPurple, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        currentEvent.date,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About this event',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<Club?>(
                    future: _mockDataService.getClubById(currentEvent.clubId),
                    builder: (context, snapshot) {
                      final clubName = snapshot.data?.name ?? 'the club';
                      return Text(
                        'Join us at $clubName for an incredible night of ${currentEvent.category} music. This event already has ${currentEvent.attendees} people interested!',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 15, height: 1.5),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // In a real app, this would lead to a booking/ticket flow
                        Get.snackbar(
                          'Coming Soon',
                          'Ticket booking for ${currentEvent.name} will be available soon!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppTheme.primaryPurple,
                          colorText: Colors.white,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Get Tickets',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
