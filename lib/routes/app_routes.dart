class AppRoutes {
  static const main = '/';
  static const login = '/login';
  static const signup = '/signup';
  
  // Clubs
  static const clubs = '/clubs';
  static const clubDetail = '/clubs/:id';
  static const reservation = '/reservation';
  
  // Events
  static const events = '/events';
  static const eventDetail = '/events/:id';
  
  // Profile
  static const profile = '/profile';
  static const userDetail = '/profile/:userId';
  static const bookingsHistory = '/bookings-history';
  static const friendsList = '/friends-list';
  static const settings = '/settings';

  // Helper methods
  static String clubDetailPath(String id) => '/clubs/$id';
  static String eventDetailPath(String id) => '/events/$id';
  static String userDetailPath(String id) => '/profile/$id';
}
