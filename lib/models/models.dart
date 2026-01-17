class Club {
  final String id;
  final String name;
  final double rating;
  final String category;
  final String location;
  final double latitude;
  final double longitude;
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
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.openUntil,
    required this.imageUrl,
    required this.description,
    this.reviews = const [],
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    String id = '';
    if (json['_id'] != null) {
      String rawId = json['_id'].toString();
      if (rawId.contains('ObjectId("')) {
        id = rawId.split('"')[1];
      } else if (json['_id'] is Map && json['_id']['\$oid'] != null) {
        id = json['_id']['\$oid'].toString();
      } else {
        id = rawId;
      }
    } else {
      id = (json['id'] ?? '').toString();
    }

    final reviewsList = (json['reviews'] as List?)
            ?.map((r) => Review.fromJson(r))
            .toList() ??
        [];

    double calculatedRating = (json['rating'] ?? 0.0).toDouble();
    if (reviewsList.isNotEmpty) {
      double totalRating = 0;
      for (var review in reviewsList) {
        totalRating += review.rating;
      }
      calculatedRating = double.parse((totalRating / reviewsList.length).toStringAsFixed(1));
    }

    return Club(
      id: id,
      name: json['name'] ?? '',
      rating: calculatedRating,
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      distance: json['distance'] ?? '',
      openUntil: json['openUntil'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      reviews: reviewsList,
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
    String id = '';
    if (json['_id'] != null) {
      String rawId = json['_id'].toString();
      if (rawId.contains('ObjectId("')) {
        id = rawId.split('"')[1];
      } else if (json['_id'] is Map && json['_id']['\$oid'] != null) {
        id = json['_id']['\$oid'].toString();
      } else {
        id = rawId;
      }
    } else {
      id = (json['id'] ?? '').toString();
    }

    return Review(
      id: id,
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
  final String clubId;
  final String date;
  final double price;
  final String category;
  final int attendees;
  final String imageUrl;

  Event({
    required this.id,
    required this.name,
    required this.clubId,
    required this.date,
    required this.price,
    required this.category,
    required this.attendees,
    required this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    String id = '';
    if (json['_id'] != null) {
      String rawId = json['_id'].toString();
      if (rawId.contains('ObjectId("')) {
        id = rawId.split('"')[1];
      } else if (json['_id'] is Map && json['_id']['\$oid'] != null) {
        id = json['_id']['\$oid'].toString();
      } else {
        id = rawId;
      }
    } else {
      id = (json['id'] ?? '').toString();
    }

    String clubIdStr = '';
    if (json['clubId'] != null) {
      String rawClubId = json['clubId'].toString();
      if (rawClubId.contains('ObjectId("')) {
        clubIdStr = rawClubId.split('"')[1];
      } else if (json['clubId'] is Map && json['clubId']['\$oid'] != null) {
        clubIdStr = json['clubId']['\$oid'].toString();
      } else {
        clubIdStr = rawClubId;
      }
    }

    return Event(
      id: id,
      name: json['name'] ?? '',
      clubId: clubIdStr,
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
  final String? qrData;

  Booking({
    required this.id,
    required this.clubName,
    required this.date,
    required this.time,
    required this.guests,
    required this.tableNumber,
    required this.totalPrice,
    this.qrData,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    String id = '';
    if (json['_id'] != null) {
      String rawId = json['_id'].toString();
      if (rawId.contains('ObjectId("')) {
        id = rawId.split('"')[1];
      } else if (json['_id'] is Map && json['_id']['\$oid'] != null) {
        id = json['_id']['\$oid'].toString();
      } else {
        id = rawId;
      }
    } else {
      id = (json['id'] ?? '').toString();
    }

    return Booking(
      id: id,
      clubName: json['clubName'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      guests: json['guests'] ?? 0,
      tableNumber: json['tableNumber'] ?? 0,
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      qrData: json['qrData'],
    );
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final String bio;
  final String avatarUrl;
  final List<String> favoriteClubs;
  final List<String> friends;
  final List<String> bookingIds;
  final Map<String, dynamic> settings;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.bio,
    required this.avatarUrl,
    this.favoriteClubs = const [],
    this.friends = const [],
    this.bookingIds = const [],
    this.settings = const {},
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String id = '';
    if (json['_id'] != null) {
      String rawId = json['_id'].toString();
      if (rawId.contains('ObjectId("')) {
        id = rawId.split('"')[1];
      } else if (json['_id'] is Map && json['_id']['\$oid'] != null) {
        id = json['_id']['\$oid'].toString();
      } else {
        id = rawId;
      }
    } else {
      id = (json['id'] ?? '').toString();
    }

    return User(
      id: id,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      favoriteClubs: (json['favoriteClubs'] as List?)?.map((e) => e.toString()).toList() ?? [],
      friends: (json['friends'] as List?)?.map((e) => e.toString()).toList() ?? [],
      bookingIds: (json['bookingIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'favoriteClubs': favoriteClubs,
      'friends': friends,
      'bookingIds': bookingIds,
      'settings': settings,
    };
  }
}

class Promotion {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final bool isNew;
  final String? clubId;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.isNew = false,
    this.clubId,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    String id = '';
    if (json['_id'] != null) {
      String rawId = json['_id'].toString();
      if (rawId.contains('ObjectId("')) {
        id = rawId.split('"')[1];
      } else if (json['_id'] is Map && json['_id']['\$oid'] != null) {
        id = json['_id']['\$oid'].toString();
      } else {
        id = rawId;
      }
    } else {
      id = (json['id'] ?? '').toString();
    }

    String? clubIdStr;
    if (json['clubId'] != null) {
      String rawClubId = json['clubId'].toString();
      if (rawClubId.contains('ObjectId("')) {
        clubIdStr = rawClubId.split('"')[1];
      } else if (json['clubId'] is Map && json['clubId']['\$oid'] != null) {
        clubIdStr = json['clubId']['\$oid'].toString();
      } else {
        clubIdStr = rawClubId;
      }
    }

    return Promotion(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isNew: json['isNew'] ?? false,
      clubId: clubIdStr,
    );
  }
}

enum SearchType {
  all,
  clubs,
  events,
}
