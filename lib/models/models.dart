class Club {
  final String id;
  final String name;
  final double rating;
  final String category; // Electronic, Hip Hop, House, etc.
  final String location;
  final String distance;
  final String openUntil;
  final String imageUrl;
  final String description;
  final List<Review> reviews;

  Club({
    required this.id,
    required this.name,
    required this.rating,
    required this.category,
    required this.location,
    required this.distance,
    required this.openUntil,
    required this.imageUrl,
    required this.description,
    this.reviews = const [],
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      distance: json['distance'] ?? '',
      openUntil: json['openUntil'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      reviews: (json['reviews'] as List?)
              ?.map((r) => Review.fromJson(r))
              .toList() ??
          [],
    );
  }
}

class Review {
  final String id;
  final String userName;
  final String userInitial;
  final double rating;
  final String date;
  final String text;

  Review({
    required this.id,
    required this.userName,
    required this.userInitial,
    required this.rating,
    required this.date,
    required this.text,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      userName: json['userName'] ?? '',
      userInitial: json['userInitial'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      date: json['date'] ?? '',
      text: json['text'] ?? '',
    );
  }
}

class Event {
  final String id;
  final String name;
  final String clubName;
  final String date;
  final double price;
  final String category;
  final int attendees;
  final String imageUrl;

  Event({
    required this.id,
    required this.name,
    required this.clubName,
    required this.date,
    required this.price,
    required this.category,
    required this.attendees,
    required this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      clubName: json['clubName'] ?? '',
      date: json['date'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      attendees: json['attendees'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class Booking {
  final String id;
  final String clubName;
  final String date;
  final String time;
  final int guests;
  final int tableNumber;
  final double totalPrice;

  Booking({
    required this.id,
    required this.clubName,
    required this.date,
    required this.time,
    required this.guests,
    required this.tableNumber,
    required this.totalPrice,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      clubName: json['clubName'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      guests: json['guests'] ?? 0,
      tableNumber: json['tableNumber'] ?? 0,
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
    );
  }
}

class User {
  final String id;
  final String username;
  final String bio;
  final String avatarUrl;

  User({
    required this.id,
    required this.username,
    required this.bio,
    required this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      username: json['username'] ?? '',
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }
}

class Promotion {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final bool isNew;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.isNew = false,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isNew: json['isNew'] ?? false,
    );
  }
}

enum SearchType {
  all,
  clubs,
  events,
}
