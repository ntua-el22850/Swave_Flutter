import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../utils/theme.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';
import '../../services/navigation_controller.dart';
import '../../widgets/state_widgets.dart';

class BookingsHistoryScreen extends StatelessWidget {
  const BookingsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockService = MockDataService();
    final userBookingIds = (AuthService.currentUser?['bookingIds'] as List?)?.map((e) => e.toString()).toList() ?? [];

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

          final allBookings = snapshot.data![0] as List<Booking>;
          final clubs = snapshot.data![1] as List<Club>;
          
          final bookings = allBookings.where((b) => userBookingIds.contains(b.id)).toList();

          bookings.sort((a, b) {
            try {
              DateTime? dateA = _parseBookingDate(a.date);
              DateTime? dateB = _parseBookingDate(b.date);
              
              if (dateA != null && dateB != null) {
                return dateB.compareTo(dateA); 
              }
            } catch (e) {
              // Fallback to string comparison if parsing fails
            }
            return b.date.compareTo(a.date);
          });

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
                          (context as Element).markNeedsBuild();
                        },
                        color: AppTheme.primaryPurple,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: bookings.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 15),
                          itemBuilder: (context, index) {
                            return _buildBookingItem(context, bookings[index], clubs);
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
            Color(0xFF7C5FDC),
            Color(0xFF4A90E2),
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

  void _showQRDialog(BuildContext context, Booking booking) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF24243E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Reservation QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                booking.clubName,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: booking.qrData ?? 'NO-DATA',
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Show this code at the entrance',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingItem(BuildContext context, Booking booking, List<Club> clubs) {
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
        onTap: () => _showQRDialog(context, booking),
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
                      'Min. Consumption',
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

  DateTime? _parseBookingDate(String dateStr) {
    try {
      
      if (dateStr.contains(',')) {
        List<String> parts = dateStr.split(',');
        if (parts.length >= 2) {
          String monthDay = parts[0].trim();
          String year = parts[1].trim();
          
          List<String> md = monthDay.split(' ');
          if (md.length == 2) {
            int month = _getMonthInt(md[0]);
            int day = int.parse(md[1]);
            int yearInt = int.parse(year);
            return DateTime(yearInt, month, day);
          }
        }
      }
      
      
      if (dateStr.contains(',')) {
         List<String> parts = dateStr.split(',');
         if (parts.length == 2 && parts[0].length == 3) {
            String monthDay = parts[1].trim();
            List<String> md = monthDay.split(' ');
            if (md.length == 2) {
              int month = _getMonthInt(md[0]);
              int day = int.parse(md[1]);
              return DateTime(2026, month, day);
            }
         }
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  int _getMonthInt(String monthStr) {
    switch (monthStr.toLowerCase()) {
      case 'jan': return 1;
      case 'feb': return 2;
      case 'mar': return 3;
      case 'apr': return 4;
      case 'may': return 5;
      case 'jun': return 6;
      case 'jul': return 7;
      case 'aug': return 8;
      case 'sep': return 9;
      case 'oct': return 10;
      case 'nov': return 11;
      case 'dec': return 12;
      default: return 1;
    }
  }

  Widget _buildBottomNavBar() {
    final NavigationController navCtrl = Get.find<NavigationController>();

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
          currentIndex: 3,
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color(0xFFE8DFF5),
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) {
            if (index != 3) {
              navCtrl.setSelectedIndex(index);
              Get.offAllNamed(AppRoutes.main);
            }
          },
        ),
      ),
    );
  }
}
