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
}
