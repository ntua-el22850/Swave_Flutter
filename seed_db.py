import pymongo
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

MONGO_URI = os.getenv("MONGO_URI", "mongodb+srv://test_user:test_password@cluster0.mongodb.net/swave_db?retryWrites=true&w=majority")

def seed_database():
    client = pymongo.MongoClient(MONGO_URI)
    # Check if database is specified in URI, if not use a default
    db = client.get_database("swave_db")

    # Clubs Data
    clubs = [
        {
            "id": "c0",
            "name": "Neon Nights",
            "rating": 4.7,
            "category": "Electronic",
            "location": "Downtown District",
            "distance": "0.5 km",
            "openUntil": "04:00 AM",
            "imageUrl": "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=800&q=80",
            "description": "Experience the ultimate neon-lit nightlife at Neon Nights. Featuring world-class DJs, state-of-the-art sound systems, and an atmosphere that will keep you dancing until dawn.",
            "reviews": [
                {
                    "id": "r1",
                    "userName": "Chris P.",
                    "userInitial": "C",
                    "rating": 5.0,
                    "date": "Nov 10, 2025",
                    "text": "Amazing atmosphere! The music was spot on and the service was excellent."
                }
            ]
        },
        {
            "id": "c1",
            "name": "Neon Pulse",
            "rating": 4.8,
            "category": "Electronic",
            "location": "123 Techno Lane, Night City",
            "distance": "1.2 km",
            "openUntil": "04:00 AM",
            "imageUrl": "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=800&q=80",
            "description": "The ultimate electronic music experience with state-of-the-art lighting."
        },
        {
            "id": "c2",
            "name": "Velvet Lounge",
            "rating": 4.5,
            "category": "Jazz",
            "location": "456 Smooth Ave, Downtown",
            "distance": "2.5 km",
            "openUntil": "02:00 AM",
            "imageUrl": "https://images.unsplash.com/photo-1514525253344-ad715d730a89?auto=format&fit=crop&w=800&q=80",
            "description": "Sophisticated jazz and cocktails in a luxurious setting."
        },
        {
            "id": "c3",
            "name": "The Bassment",
            "rating": 4.6,
            "category": "Hip Hop",
            "location": "789 Rhythm St, Westside",
            "distance": "3.1 km",
            "openUntil": "03:30 AM",
            "imageUrl": "https://images.unsplash.com/photo-1571266028243-3716f02d2d2e?auto=format&fit=crop&w=800&q=80",
            "description": "Raw energy and the best hip hop beats in the city."
        },
        {
            "id": "c4",
            "name": "Elysium House",
            "rating": 4.9,
            "category": "House",
            "location": "101 Cloud Blvd, Uptown",
            "distance": "0.8 km",
            "openUntil": "05:00 AM",
            "imageUrl": "https://images.unsplash.com/photo-1574391884720-bbc37bb15932?auto=format&fit=crop&w=800&q=80",
            "description": "Heavenly house music and an ethereal atmosphere."
        }
    ]

    # Events Data
    events = [
        {
            "id": "e0",
            "name": "Electric Dreams Festival",
            "clubName": "Neon Nights",
            "date": "Sat, Jan 20",
            "price": 45.0,
            "category": "Electronic",
            "attendees": 1200,
            "imageUrl": "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=800&q=80"
        },
        {
            "id": "e1",
            "name": "Cyber Techno Rave",
            "clubName": "Neon Pulse",
            "date": "Sat, Jan 14",
            "price": 35.0,
            "category": "Electronic",
            "attendees": 850,
            "imageUrl": "https://images.unsplash.com/photo-1505236858219-8359eb29e329?auto=format&fit=crop&w=800&q=80"
        }
    ]

    # Promotions Data
    promotions = [
        {
            "id": "p1",
            "title": "2-for-1 Cocktails",
            "description": "Enjoy 2-for-1 cocktails all night at Sky Deck every Thursday!",
            "imageUrl": "https://images.unsplash.com/photo-1572116469696-31de0f17cc34",
            "isNew": True
        }
    ]

    # Clear existing data and insert new data
    db.clubs.delete_many({})
    db.clubs.insert_many(clubs)
    
    db.events.delete_many({})
    db.events.insert_many(events)
    
    db.promotions.delete_many({})
    db.promotions.insert_many(promotions)

    print("Database seeded successfully!")

if __name__ == "__main__":
    seed_database()
