import '../models/models.dart';

class MockDataService {
  static final List<Club> _mockClubs = [
    Club(
      id: 'c0',
      name: 'Neon Nights',
      rating: 4.7,
      category: 'Electronic',
      location: 'Downtown District',
      distance: '0.5 km',
      openUntil: '04:00 AM',
      imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7',
      description: 'Experience the ultimate neon-lit nightlife at Neon Nights. Featuring world-class DJs, state-of-the-art sound systems, and an atmosphere that will keep you dancing until dawn. Join us for an unforgettable night of electronic music and vibrant energy.',
      reviews: [
        Review(
          id: 'r1',
          userName: 'Chris P.',
          userInitial: 'C',
          rating: 5.0,
          date: 'Nov 10, 2025',
          text: 'Amazing atmosphere! The music was spot on and the service was excellent.',
        ),
      ],
    ),
    Club(
      id: 'c1',
      name: 'Neon Pulse',
      rating: 4.8,
      category: 'Electronic',
      location: '123 Techno Lane, Night City',
      distance: '1.2 km',
      openUntil: '04:00 AM',
      imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7',
      description: 'The ultimate electronic music experience with state-of-the-art lighting.',
    ),
    Club(
      id: 'c2',
      name: 'Velvet Lounge',
      rating: 4.5,
      category: 'Jazz',
      location: '456 Smooth Ave, Downtown',
      distance: '2.5 km',
      openUntil: '02:00 AM',
      imageUrl: 'https://images.unsplash.com/photo-1514525253344-ad715d730a89',
      description: 'Sophisticated jazz and cocktails in a luxurious setting.',
    ),
    Club(
      id: 'c3',
      name: 'The Bassment',
      rating: 4.6,
      category: 'Hip Hop',
      location: '789 Rhythm St, Westside',
      distance: '3.1 km',
      openUntil: '03:30 AM',
      imageUrl: 'https://images.unsplash.com/photo-1571266028243-3716f02d2d2e',
      description: 'Raw energy and the best hip hop beats in the city.',
    ),
    Club(
      id: 'c4',
      name: 'Elysium House',
      rating: 4.9,
      category: 'House',
      location: '101 Cloud Blvd, Uptown',
      distance: '0.8 km',
      openUntil: '05:00 AM',
      imageUrl: 'https://images.unsplash.com/photo-1574391884720-bbc37bb15932',
      description: 'Heavenly house music and an ethereal atmosphere.',
    ),
    Club(
      id: 'c5',
      name: 'Retro Disco',
      rating: 4.2,
      category: '80s/90s',
      location: '202 Flashback Rd, East End',
      distance: '4.0 km',
      openUntil: '03:00 AM',
      imageUrl: 'https://images.unsplash.com/photo-1566737236500-c8ac43014a67',
      description: 'Dance to the greatest hits of the past decades.',
    ),
    Club(
      id: 'c6',
      name: 'Underground Techno',
      rating: 4.7,
      category: 'Electronic',
      location: '303 Dark Ave, Industrial District',
      distance: '5.2 km',
      openUntil: '06:00 AM',
      imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
      description: 'Serious techno for serious dancers.',
    ),
    Club(
      id: 'c7',
      name: 'Blue Note',
      rating: 4.4,
      category: 'Blues',
      location: '404 Soul St, Old Town',
      distance: '1.5 km',
      openUntil: '01:00 AM',
      imageUrl: 'https://images.unsplash.com/photo-1511192336575-5a79af67a629',
      description: 'The soul of the city in every note.',
    ),
    Club(
      id: 'c8',
      name: 'Sky Deck',
      rating: 4.6,
      category: 'Cocktail/Lounge',
      location: '505 Horizon Dr, Highrise',
      distance: '2.2 km',
      openUntil: '02:00 AM',
      imageUrl: 'https://images.unsplash.com/photo-1572116469696-31de0f17cc34',
      description: 'Breathtaking views and exquisite cocktails.',
    ),
    Club(
      id: 'c9',
      name: 'Urban Beats',
      rating: 4.3,
      category: 'Hip Hop',
      location: '606 Streetwise Wy, Midtown',
      distance: '1.8 km',
      openUntil: '03:00 AM',
      imageUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30',
      description: 'Where the street meets the beat.',
    ),
    Club(
      id: 'c10',
      name: 'Vinyl Haven',
      rating: 4.7,
      category: 'Indie/Alternative',
      location: '707 Record Ln, Artsy District',
      distance: '2.7 km',
      openUntil: '02:30 AM',
      imageUrl: 'https://images.unsplash.com/photo-1459749411177-042180ce673c',
      description: 'Pure sound, pure vibes, pure vinyl.',
    ),
    Club(
      id: 'c11',
      name: 'Salsa Heat',
      rating: 4.5,
      category: 'Latin',
      location: '808 Caliente Way, Little Havana',
      distance: '3.5 km',
      openUntil: '03:00 AM',
      imageUrl: 'https://images.unsplash.com/photo-1545128485-c400e7702796',
      description: 'The hottest salsa nights in town.',
    ),
  ];

  static final List<Event> _mockEvents = [
    Event(
      id: 'e0',
      name: 'Electronic Hits',
      clubName: 'Neon Nights',
      date: 'Sat, Jan 20',
      price: 15.0,
      category: 'Electronic',
      attendees: 200,
      imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
    ),
    Event(
      id: 'e5',
      name: 'House Party',
      clubName: 'Elysium House',
      date: 'Sun, Jan 21',
      price: 20.0,
      category: 'House',
      attendees: 150,
      imageUrl: 'https://images.unsplash.com/photo-1574391884720-bbc37bb15932',
    ),
    Event(
      id: 'e6',
      name: 'Hip Hop Night',
      clubName: 'The Bassment',
      date: 'Fri, Jan 19',
      price: 18.0,
      category: 'Hip Hop',
      attendees: 250,
      imageUrl: 'https://images.unsplash.com/photo-1571266028243-3716f02d2d2e',
    ),
    Event(
      id: 'e1',
      name: 'Techno Night with DJ Spark',
      clubName: 'Neon Pulse',
      date: 'Sat, Jan 14',
      price: 25.0,
      category: 'Electronic',
      attendees: 450,
      imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
    ),
    Event(
      id: 'e2',
      name: 'Smooth Jazz Evening',
      clubName: 'Velvet Lounge',
      date: 'Fri, Jan 13',
      price: 15.0,
      category: 'Jazz',
      attendees: 120,
      imageUrl: 'https://images.unsplash.com/photo-1511192336575-5a79af67a629',
    ),
    Event(
      id: 'e3',
      name: 'Hip Hop Battle',
      clubName: 'The Bassment',
      date: 'Sat, Jan 14',
      price: 20.0,
      category: 'Hip Hop',
      attendees: 300,
      imageUrl: 'https://images.unsplash.com/photo-1571266028243-3716f02d2d2e',
    ),
    Event(
      id: 'e4',
      name: 'House Party Deluxe',
      clubName: 'Elysium House',
      date: 'Fri, Jan 13',
      price: 30.0,
      category: 'House',
      attendees: 500,
      imageUrl: 'https://images.unsplash.com/photo-1574391884720-bbc37bb15932',
    ),
  ];

  static final List<Promotion> _mockPromotions = [
    Promotion(
      id: 'p1',
      title: '2-for-1 Cocktails',
      description: 'Enjoy 2-for-1 cocktails all night at Sky Deck every Thursday!',
      imageUrl: 'https://images.unsplash.com/photo-1572116469696-31de0f17cc34',
      isNew: true,
    ),
    Promotion(
      id: 'p2',
      title: 'VIP Entrance',
      description: 'Get free VIP entrance at Neon Pulse this Saturday with Swave.',
      imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7',
      isNew: false,
    ),
    Promotion(
      id: 'p3',
      title: 'Latin Night Special',
      description: 'Free salsa lessons from 8 PM to 10 PM at Salsa Heat.',
      imageUrl: 'https://images.unsplash.com/photo-1545128485-c400e7702796',
      isNew: true,
    ),
  ];

  static final List<Booking> _mockBookings = [
    Booking(
      id: 'b1',
      clubName: 'Neon Pulse',
      date: 'Jan 07, 2026',
      time: '11:00 PM',
      guests: 4,
      tableNumber: 12,
      totalPrice: 100.0,
    ),
    Booking(
      id: 'b2',
      clubName: 'Velvet Lounge',
      date: 'Dec 31, 2025',
      time: '10:00 PM',
      guests: 2,
      tableNumber: 5,
      totalPrice: 60.0,
    ),
  ];

  static final List<User> _mockFriends = [
    User(
      id: 'f1',
      username: 'alex_night',
      bio: 'Party animal and music lover.',
      avatarUrl: 'https://i.pravatar.cc/150?u=f1',
    ),
    User(
      id: 'f2',
      username: 'sarah_vibes',
      bio: 'Always looking for the next best beat.',
      avatarUrl: 'https://i.pravatar.cc/150?u=f2',
    ),
    User(
      id: 'f3',
      username: 'mike_beats',
      bio: 'Techno enthusiast.',
      avatarUrl: 'https://i.pravatar.cc/150?u=f3',
    ),
    User(
      id: 'f4',
      username: 'lisa_jazz',
      bio: 'Jazz and wine connoisseur.',
      avatarUrl: 'https://i.pravatar.cc/150?u=f4',
    ),
  ];

  static final List<Club> _mockVisitedClubs = [
    Club(
      id: 'c1',
      name: 'Neon Pulse',
      rating: 5.0, // User's personal rating
      category: 'Electronic',
      location: '123 Techno Lane, Night City',
      distance: '1.2 km',
      openUntil: '04:00 AM',
      imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7',
      description: 'The ultimate electronic music experience with state-of-the-art lighting.',
    ),
    Club(
      id: 'c4',
      name: 'Elysium House',
      rating: 4.5, // User's personal rating
      category: 'House',
      location: '101 Cloud Blvd, Uptown',
      distance: '0.8 km',
      openUntil: '05:00 AM',
      imageUrl: 'https://images.unsplash.com/photo-1574391884720-bbc37bb15932',
      description: 'Heavenly house music and an ethereal atmosphere.',
    ),
  ];

  List<Club> getClubs() => _mockClubs;
  List<Event> getEvents() => _mockEvents;
  List<Promotion> getPromotions() => _mockPromotions;
  List<Booking> getBookings() => _mockBookings;
  List<User> getFriends() => _mockFriends;
  List<Club> getVisitedClubs() => _mockVisitedClubs;

  List<Event> getEventsByClub(String clubName) {
    return _mockEvents.where((event) => event.clubName == clubName).toList();
  }
}
