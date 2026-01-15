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
            "name": "Neon Nights",
            "rating": 4.7,
            "category": "Electronic",
            "location": "Downtown District",
            "latitude": 37.9838,
            "longitude": 23.7275,
            "distance": "0.5 km",
            "openUntil": "04:00 AM",
            "imageUrl": "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=800&q=80",
            "description": "Experience the ultimate neon-lit nightlife at Neon Nights. Featuring world-class DJs, state-of-the-art sound systems, and an atmosphere that will keep you dancing until dawn.",
            "reviews": [
                {
                    "userName": "Chris P.",
                    "userInitial": "C",
                    "rating": 5.0,
                    "date": "Nov 10, 2025",
                    "text": "Amazing atmosphere! The music was spot on and the service was excellent."
                }
            ]
        },
        {
            "name": "Neon Pulse",
            "rating": 4.8,
            "category": "Electronic",
            "location": "123 Techno Lane, Night City",
            "latitude": 37.9755,
            "longitude": 23.7348,
            "distance": "1.2 km",
            "openUntil": "04:00 AM",
            "imageUrl": "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=800&q=80",
            "description": "The ultimate electronic music experience with state-of-the-art lighting."
        },
        {
            "name": "Velvet Lounge",
            "rating": 4.5,
            "category": "Jazz",
            "location": "456 Smooth Ave, Downtown",
            "latitude": 37.9902,
            "longitude": 23.7251,
            "distance": "2.5 km",
            "openUntil": "02:00 AM",
            "imageUrl": "https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?auto=format&fit=crop&w=800&q=80",
            "description": "Sophisticated jazz and cocktails in a luxurious setting."
        },
        {
            "name": "The Bassment",
            "rating": 4.6,
            "category": "Hip Hop",
            "location": "789 Rhythm St, Westside",
            "latitude": 37.9680,
            "longitude": 23.7150,
            "distance": "3.1 km",
            "openUntil": "03:30 AM",
            "imageUrl": "https://images.unsplash.com/photo-1598387993281-cecf8b71a8f8?auto=format&fit=crop&w=800&q=80",
            "description": "Raw energy and the best hip hop beats in the city."
        },
        {
            "name": "Elysium House",
            "rating": 4.9,
            "category": "House",
            "location": "101 Cloud Blvd, Uptown",
            "latitude": 37.9715,
            "longitude": 23.7430,
            "distance": "0.8 km",
            "openUntil": "05:00 AM",
            "imageUrl": "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&w=800&q=80",
            "description": "Heavenly house music and an ethereal atmosphere."
        },
        {
            "name": "Crimson Club",
            "rating": 4.4,
            "category": "R&B",
            "location": "212 Soul Street, Midtown",
            "latitude": 37.9820,
            "longitude": 23.7200,
            "distance": "1.8 km",
            "openUntil": "03:00 AM",
            "imageUrl": "https://images.unsplash.com/photo-1516450137517-162bfbeb8dba?auto=format&fit=crop&w=800&q=80",
            "description": "Smooth R&B vibes with live performances and an intimate dance floor."
        },
        {
            "name": "Apex Rooftop",
            "rating": 4.7,
            "category": "Mixed",
            "location": "555 Sky Tower, Financial District",
            "latitude": 37.9888,
            "longitude": 23.7380,
            "distance": "2.2 km",
            "openUntil": "02:30 AM",
            "imageUrl": "https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?auto=format&fit=crop&w=800&q=80",
            "description": "Stunning city views from our rooftop terrace with premium bottle service."
        },
        {
            "name": "Underground Techno",
            "rating": 4.9,
            "category": "Techno",
            "location": "33 Basement Ave, Industrial Zone",
            "latitude": 37.9650,
            "longitude": 23.7100,
            "distance": "3.5 km",
            "openUntil": "06:00 AM",
            "imageUrl": "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&w=800&q=80",
            "description": "Raw industrial space hosting the city's best underground techno events."
        },
        {
            "name": "Salsa Paradise",
            "rating": 4.3,
            "category": "Latin",
            "location": "88 Tropical Way, Cultural District",
            "latitude": 37.9780,
            "longitude": 23.7320,
            "distance": "1.5 km",
            "openUntil": "03:00 AM",
            "imageUrl": "https://images.unsplash.com/photo-1504609773096-104ff2c73ba4?auto=format&fit=crop&w=800&q=80",
            "description": "Hot Latin rhythms and dance lessons every Friday night."
        },
        {
            "name": "Retro Revival",
            "rating": 4.6,
            "category": "Mixed",
            "location": "404 Nostalgia Lane, Old Town",
            "latitude": 37.9850,
            "longitude": 23.7180,
            "distance": "1.9 km",
            "openUntil": "02:00 AM",
            "imageUrl": "https://images.unsplash.com/photo-1545128485-c400e7702796?auto=format&fit=crop&w=800&q=80",
            "description": "80s and 90s throwback nights with classic hits and vintage cocktails."
        }
    ]

    # Clear existing data
    db.clubs.delete_many({})
    db.events.delete_many({})
    db.promotions.delete_many({})

    # Insert clubs and get their generated IDs
    club_ids = db.clubs.insert_many(clubs).inserted_ids

    # Events Data
    events = [
        {
            "name": "Electric Dreams Festival",
            "clubId": club_ids[0],
            "date": "Sat, Jan 20",
            "price": 45.0,
            "category": "Electronic",
            "attendees": 1200,
            "imageUrl": "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Cyber Techno Rave",
            "clubId": club_ids[1],
            "date": "Sat, Jan 18",
            "price": 35.0,
            "category": "Electronic",
            "attendees": 850,
            "imageUrl": "https://images.unsplash.com/photo-1505236858219-8359eb29e329?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Jazz & Wine Night",
            "clubId": club_ids[2],
            "date": "Fri, Jan 17",
            "price": 25.0,
            "category": "Jazz",
            "attendees": 180,
            "imageUrl": "https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Hip Hop Legends Tour",
            "clubId": club_ids[3],
            "date": "Sun, Jan 19",
            "price": 50.0,
            "category": "Hip Hop",
            "attendees": 650,
            "imageUrl": "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "House Music Marathon",
            "clubId": club_ids[4],
            "date": "Sat, Jan 25",
            "price": 40.0,
            "category": "House",
            "attendees": 950,
            "imageUrl": "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "R&B Sunset Session",
            "clubId": club_ids[5],
            "date": "Fri, Jan 24",
            "price": 30.0,
            "category": "R&B",
            "attendees": 320,
            "imageUrl": "https://images.unsplash.com/photo-1506157786151-b8491531f063?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Rooftop Fridays",
            "clubId": club_ids[6],
            "date": "Every Friday",
            "price": 35.0,
            "category": "Mixed",
            "attendees": 450,
            "imageUrl": "https://images.unsplash.com/photo-1519214605650-76a613ee3245?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Techno Underground",
            "clubId": club_ids[7],
            "date": "Sat, Jan 18",
            "price": 30.0,
            "category": "Techno",
            "attendees": 780,
            "imageUrl": "https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "Salsa Night Fever",
            "clubId": club_ids[8],
            "date": "Thu, Jan 23",
            "price": 20.0,
            "category": "Latin",
            "attendees": 280,
            "imageUrl": "https://images.unsplash.com/photo-1508700929628-666bc8bd84ea?auto=format&fit=crop&w=800&q=80"
        },
        {
            "name": "80s Rewind Party",
            "clubId": club_ids[9],
            "date": "Sat, Jan 25",
            "price": 25.0,
            "category": "Mixed",
            "attendees": 520,
            "imageUrl": "https://images.unsplash.com/photo-1518834107812-67b0b7c58434?auto=format&fit=crop&w=800&q=80"
        }
    ]

    # Promotions Data
    promotions = [
        {
            "clubId": club_ids[0],
            "title": "2-for-1 Cocktails",
            "description": "Enjoy 2-for-1 cocktails all night every Thursday!",
            "imageUrl": "https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&w=800&q=80",
            "isNew": True
        },
        {
            "clubId": club_ids[1],
            "title": "Ladies Night",
            "description": "Free entry for ladies before midnight every Wednesday!",
            "imageUrl": "https://images.unsplash.com/photo-1566417713940-fe7c737a9ef2?auto=format&fit=crop&w=800&q=80",
            "isNew": True
        },
        {
            "clubId": club_ids[4],
            "title": "Student Discount",
            "description": "Show your student ID for 30% off entry every night!",
            "imageUrl": "https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80",
            "isNew": False
        },
        {
            "clubId": club_ids[6],
            "title": "Early Bird Special",
            "description": "Arrive before 10 PM and get a free welcome drink!",
            "imageUrl": "https://images.unsplash.com/photo-1470337458703-46ad1756a187?auto=format&fit=crop&w=800&q=80",
            "isNew": True
        },
        {
            "clubId": club_ids[7],
            "title": "VIP Table Booking",
            "description": "Book a VIP table and get complimentary bottle service!",
            "imageUrl": "https://images.unsplash.com/photo-1572116469696-31de0f17cc34?auto=format&fit=crop&w=800&q=80",
            "isNew": False
        },
        {
            "clubId": club_ids[8],
            "title": "Free Dance Lesson",
            "description": "Join our free salsa lesson from 9-10 PM every Friday!",
            "imageUrl": "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=800&q=80",
            "isNew": True
        }
    ]

    db.events.insert_many(events)
    db.promotions.insert_many(promotions)

    print("Database seeded successfully!")
    print(f"Added {len(clubs)} clubs, {len(events)} events, and {len(promotions)} promotions")

if __name__ == "__main__":
    seed_database()
