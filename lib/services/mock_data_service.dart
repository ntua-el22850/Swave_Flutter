import '../models/models.dart';
import 'mongodb_service.dart';

class MockDataService {
  Future<List<Club>> getClubs() async {
    final clubs = await MongoDBService.getClubs();
    return clubs.map((c) => Club.fromJson(c)).toList();
  }

  Future<List<Event>> getEvents() async {
    final events = await MongoDBService.getEvents();
    return events.map((e) => Event.fromJson(e)).toList();
  }

  Future<List<Promotion>> getPromotions() async {
    final promotions = await MongoDBService.getPromotions();
    return promotions.map((p) => Promotion.fromJson(p)).toList();
  }

  Future<List<Booking>> getBookings() async {
    final bookings = await MongoDBService.getBookings();
    return bookings.map((b) => Booking.fromJson(b)).toList();
  }

  Future<List<User>> getFriends() async {
    return [];
  }

  Future<List<Club>> getVisitedClubs() async {
    return [];
  }

  Future<List<Event>> getEventsByClub(String clubId) async {
    final events = await getEvents();
    return events.where((event) => event.clubId == clubId).toList();
  }

  Future<Club?> getClubById(String clubId) async {
    final clubs = await getClubs();
    try {
      return clubs.firstWhere((c) => c.id == clubId);
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> searchClubsAndEvents({
    required String query,
    SearchType searchType = SearchType.all,
    List<String>? categories,
  }) async {
    query = query.toLowerCase();
    List<dynamic> results = [];

    if (searchType == SearchType.clubs || searchType == SearchType.all) {
      final allClubs = await getClubs();
      final filteredClubs = allClubs.where((club) {
        final matchesQuery = club.name.toLowerCase().contains(query) ||
            club.category.toLowerCase().contains(query) ||
            club.location.toLowerCase().contains(query);
        final matchesCategory = categories == null ||
            categories.isEmpty ||
            categories.contains(club.category);
        return matchesQuery && matchesCategory;
      }).toList();
      results.addAll(filteredClubs);
    }

    if (searchType == SearchType.events || searchType == SearchType.all) {
      final allEvents = await getEvents();
      final allClubs = await getClubs();

      final filteredEvents = allEvents.where((event) {
        final club = allClubs.firstWhere((c) => c.id == event.clubId,
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
        final matchesQuery = event.name.toLowerCase().contains(query) ||
            club.name.toLowerCase().contains(query) ||
            event.category.toLowerCase().contains(query);
        final matchesCategory = categories == null ||
            categories.isEmpty ||
            categories.contains(event.category);
        return matchesQuery && matchesCategory;
      }).toList();
      results.addAll(filteredEvents);
    }

    return results;
  }

  Future<List<String>> getAllClubCategories() async {
    final clubs = await getClubs();
    return clubs.map((club) => club.category).toSet().toList();
  }

  Future<List<String>> getAllEventCategories() async {
    final events = await getEvents();
    return events.map((event) => event.category).toSet().toList();
  }

  Future<List<String>> getAllCategories() async {
    final clubCategories = await getAllClubCategories();
    final eventCategories = await getAllEventCategories();
    return (clubCategories + eventCategories).toSet().toList();
  }
}
