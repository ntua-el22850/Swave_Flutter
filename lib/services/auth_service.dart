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
    };

    await MongoDBService.usersCollection!.insert(user);
    // After insert, 'user' map includes '_id' of type ObjectId.
    // We convert it to string to avoid type errors in the UI.
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
}
