import 'mongodb_service.dart';
import 'auth_middleware.dart';

class AuthService {
  static Map<String, dynamic>? _currentUser;

  static Map<String, dynamic>? get currentUser => _currentUser;

  static Future<bool> login(String username, String password) async {
    final user = await MongoDBService.usersCollection!.findOne({
      'username': username,
      'password': password,
    });

    if (user != null) {
      _currentUser = user;
      AuthMiddleware.isAuthenticated = true;
      return true;
    }
    return false;
  }

  static Future<bool> signup(String username, String email, String password) async {
    final existingUser = await MongoDBService.usersCollection!.findOne({
      'username': username,
    });

    if (existingUser != null) return false;

    final Map<String, dynamic> user = {
      'username': username,
      'email': email,
      'password': password,
      'bio': 'New Swave user',
      'avatarUrl': 'https://i.pravatar.cc/150?u=$username',
      'favoriteClubs': [],
      'friends': [],
      'bookingIds': [],
      'settings': {
        'notifications': true,
        'darkMode': true,
        'language': 'English',
      },
    };

    await MongoDBService.usersCollection!.insert(user);
    if (user.containsKey('_id')) {
      user['_id'] = user['_id'].toString();
    }
    _currentUser = user;
    AuthMiddleware.isAuthenticated = true;
    return true;
  }

  static void logout() {
    _currentUser = null;
    AuthMiddleware.isAuthenticated = false;
  }

  static Future<void> toggleFavorite(String clubId) async {
    if (_currentUser == null) return;

    final List<dynamic> favorites = List.from(_currentUser!['favoriteClubs'] ?? []);
    if (favorites.contains(clubId)) {
      favorites.remove(clubId);
    } else {
      favorites.add(clubId);
    }

    _currentUser!['favoriteClubs'] = favorites;
    await MongoDBService.updateUser(_currentUser!['_id'].toString().replaceAll('ObjectId("', '').replaceAll('")', ''), _currentUser!);
  }

  static bool isFavorite(String clubId) {
    if (_currentUser == null) return false;
    final List<dynamic> favorites = _currentUser!['favoriteClubs'] ?? [];
    return favorites.contains(clubId);
  }

  static Future<void> updateSettings(Map<String, dynamic> settings) async {
    if (_currentUser == null) return;
    _currentUser!['settings'] = settings;
    await MongoDBService.updateUser(_currentUser!['_id'].toString().replaceAll('ObjectId("', '').replaceAll('")', ''), _currentUser!);
  }

  static Future<void> addBooking(String bookingId) async {
    if (_currentUser == null) return;
    final List<dynamic> bookings = List.from(_currentUser!['bookingIds'] ?? []);
    if (!bookings.contains(bookingId)) {
      bookings.add(bookingId);
      _currentUser!['bookingIds'] = bookings;
      await MongoDBService.updateUser(_currentUser!['_id'].toString().replaceAll('ObjectId("', '').replaceAll('")', ''), _currentUser!);
    }
  }
}
