import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MongoDBService {
  static Db? _db;
  static DbCollection? clubsCollection;
  static DbCollection? eventsCollection;
  static DbCollection? promotionsCollection;
  static DbCollection? bookingsCollection;
  static DbCollection? usersCollection;

  static Future<void> connect() async {
    if (_db != null && _db!.isConnected) return;

    final uri = dotenv.env['MONGO_URI'];
    if (uri == null) {
      throw Exception('MONGO_URI not found in .env file');
    }

    _db = await Db.create(uri);
    await _db!.open();
    
    clubsCollection = _db!.collection('clubs');
    eventsCollection = _db!.collection('events');
    promotionsCollection = _db!.collection('promotions');
    bookingsCollection = _db!.collection('bookings');
    usersCollection = _db!.collection('users');
  }

  static Future<List<Map<String, dynamic>>> getClubs() async {
    return await clubsCollection!.find().toList();
  }

  static Future<List<Map<String, dynamic>>> getEvents() async {
    return await eventsCollection!.find().toList();
  }

  static Future<List<Map<String, dynamic>>> getPromotions() async {
    return await promotionsCollection!.find().toList();
  }

  static Future<List<Map<String, dynamic>>> getBookings() async {
    return await bookingsCollection!.find().toList();
  }

  static Future<void> createBooking(Map<String, dynamic> booking) async {
    await bookingsCollection!.insert(booking);
  }

  static Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await usersCollection!.update(
      where.id(ObjectId.fromHexString(userId)),
      modify.set('favoriteClubs', data['favoriteClubs'])
            .set('friends', data['friends'])
            .set('bookingIds', data['bookingIds'])
            .set('settings', data['settings'])
            .set('bio', data['bio'])
            .set('avatarUrl', data['avatarUrl']),
    );
  }

  static Future<List<Map<String, dynamic>>> getClubsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final objectIds = ids.map((id) => ObjectId.fromHexString(id)).toList();
    return await clubsCollection!.find(where.oneFrom('_id', objectIds)).toList();
  }

  static Future<List<Map<String, dynamic>>> getUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final objectIds = ids.map((id) => ObjectId.fromHexString(id)).toList();
    return await usersCollection!.find(where.oneFrom('_id', objectIds)).toList();
  }

  static Future<void> addReviewToClub(String clubId, Map<String, dynamic> reviewData) async {
    await clubsCollection!.update(
      where.id(ObjectId.fromHexString(clubId)),
      modify.push('reviews', reviewData),
    );

    final club = await clubsCollection!.findOne(where.id(ObjectId.fromHexString(clubId)));
    if (club != null && club['reviews'] != null) {
      final reviews = club['reviews'] as List;
      if (reviews.isNotEmpty) {
        double totalRating = 0;
        for (var r in reviews) {
          totalRating += (r['rating'] ?? 0).toDouble();
        }
        double averageRating = totalRating / reviews.length;
        
        await clubsCollection!.update(
          where.id(ObjectId.fromHexString(clubId)),
          modify.set('rating', double.parse(averageRating.toStringAsFixed(1))),
        );
      }
    }
  }
}
