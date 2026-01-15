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

    // Ensure we use swave_db by appending it to the URI if it's not already there
    // or by letting Db.create handle it if the URI is correctly formatted.
    _db = await Db.create(uri);
    await _db!.open();

    // If the URI didn't specify a database, mongo_dart might default to 'test'.
    // We can't easily change the database on an open connection in mongo_dart like in other drivers.
    // The best way is to ensure the URI has the database name.
    // However, if we are already connected, we can try to re-open with the correct db if needed,
    // but a simpler way is to just use the database name in the connection string.
    
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
}
