import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/theme.dart';
import '../../services/mock_data_service.dart';
import '../../models/models.dart';
import '../../widgets/state_widgets.dart';

class BookingsHistoryScreen extends StatelessWidget {
  const BookingsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockService = MockDataService();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          mockService.getBookings(),
          mockService.getClubs(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          final bookings = snapshot.data![0] as List<Booking>;
          final clubs = snapshot.data![1] as List<Club>;

          return Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: bookings.isEmpty
                    ? const EmptyStateWidget(
                        title: 'No bookings yet',
                        message: 'You haven\'t made any reservations. Explore clubs and events to get started!',
                        icon: Icons.history_toggle_off,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          // Trigger rebuild
                          (context as Element).markNeedsBuild();
                        },
                        color: AppTheme.primaryPurple,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: bookings.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 15),
                          itemBuilder: (context, index) {
                            return _buildBookingItem(bookings[index], clubs);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C5FDC), // Purple
            Color(0xFF4A90E2), // Blueish
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Previously Booked Clubs/Events',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem(Booking booking, List<Club> clubs) {
    // Try to find a club with the same name to get an image
    final club = clubs.firstWhere(
      (c) => c.name == booking.clubName,
      orElse: () => Club(
          id: '',
          name: booking.clubName,
          rating: 0,
          category: '',
          location: '',
          latitude: 0,
          longitude: 0,
          distance: '',
          openUntil: '',
          imageUrl: '',
          description: ''),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF24243E),
            const Color(0xFF24243E).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {},
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    club.imageUrl,
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 65,
                      height: 65,
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      child: const Icon(
                        Icons.confirmation_number_outlined,
                        color: AppTheme.primaryPurple,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.clubName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking.date} • ${booking.time}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${booking.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Paid',
                      style: TextStyle(
                        color: Colors.greenAccent.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBookingDetail(Icons.people_outline, '${booking.guests} Guests'),
                  _buildBookingDetail(Icons.table_bar_outlined, 'Table ${booking.tableNumber}'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'DETAILS',
                      style: TextStyle(
                        color: AppTheme.primaryPurple,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetail(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF7C5FDC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_bar),
              label: 'Clubs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: 3, // Profile selected
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color(0xFFE8DFF5),
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
    );
  }
}
