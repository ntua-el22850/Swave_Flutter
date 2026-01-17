import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../../models/models.dart';
import '../../utils/theme.dart';
import '../../services/mongodb_service.dart';
import '../../services/auth_service.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  late Club club;
  String? selectedTable;
  final double basePrice = 200.0;

  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  int guestsCount = 4;

  final List<String> bookedTables = ['T2', 'T5', 'T8'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (Get.arguments is Club) {
      club = Get.arguments as Club;
      selectedDate = now.add(const Duration(days: 1));
    } else if (Get.arguments is Map) {
      club = Get.arguments['club'] as Club;
      String dateStr = Get.arguments['date'] ?? '';
      selectedDate = _parseDate(dateStr);
    } else {
      selectedDate = now.add(const Duration(days: 1));
    }

    final today = DateTime(now.year, now.month, now.day);
    if (selectedDate.isBefore(today)) {
      selectedDate = today;
    }

    selectedTime = const TimeOfDay(hour: 21, minute: 0);
  }

  DateTime _parseDate(String dateStr) {
    if (dateStr.isEmpty) return DateTime.now().add(const Duration(days: 1));
    try {
      final months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
        'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
      };

      for (var monthName in months.keys) {
        if (dateStr.contains(monthName)) {
          final numbers = RegExp(r'\d+').allMatches(dateStr).map((m) => m.group(0)!).toList();
          if (numbers.isNotEmpty) {
            int day = int.parse(numbers[0]);
            int year = numbers.length > 1 ? int.parse(numbers[1]) : DateTime.now().year;
            if (year < 100) year += 2000;
            return DateTime(year, months[monthName]!, day);
          }
        }
      }

      return DateTime.tryParse(dateStr) ?? DateTime.now().add(const Duration(days: 1));
    } catch (e) {
      return DateTime.now().add(const Duration(days: 1));
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Reservation Page',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reserve A Table',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildClubCard(),
              const SizedBox(height: 24),
              _buildReservationSummary(),
              const SizedBox(height: 32),
              _buildSelectTableSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClubCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              club.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      club.rating.toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryPurple, width: 1),
                      ),
                      child: Text(
                        club.category,
                        style: const TextStyle(
                          color: AppTheme.primaryPurple,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reservation Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(Icons.business, 'Club Name', club.name),
          _buildEditableSummaryRow(
            Icons.calendar_today,
            'Date',
            _formatDate(selectedDate),
            () async {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate.isBefore(today) ? today : selectedDate,
                firstDate: today,
                lastDate: today.add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: AppTheme.primaryPurple,
                        onPrimary: Colors.white,
                        surface: Color(0xFF24243E),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && picked != selectedDate) {
                setState(() => selectedDate = picked);
              }
            },
          ),
          _buildEditableSummaryRow(
            Icons.access_time,
            'Time',
            _formatTime(selectedTime),
            () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: selectedTime,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: AppTheme.primaryPurple,
                        onPrimary: Colors.white,
                        surface: Color(0xFF24243E),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && picked != selectedTime) {
                setState(() => selectedTime = picked);
              }
            },
          ),
          _buildGuestCountRow(),
          _buildSummaryRow(Icons.table_restaurant, 'Table Number', selectedTable ?? 'Not selected'),
          const Divider(color: Colors.white10, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Minimum Consumption',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              Text(
                '\$${basePrice.toInt()}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (selectedTable == null) {
                  _showTableSuggestionDialog();
                } else {
                  _confirmReservation();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Confirm Reservation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryPurple),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableSummaryRow(IconData icon, String label, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryPurple),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(color: Colors.white70)),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.edit, size: 14, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestCountRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 20, color: AppTheme.primaryPurple),
          const SizedBox(width: 12),
          const Text('Guests', style: TextStyle(color: Colors.white70)),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                  onPressed: () {
                    if (guestsCount > 1) {
                      setState(() => guestsCount--);
                    }
                  },
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
                Text(
                  '$guestsCount',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  onPressed: () {
                    if (guestsCount < 14) {
                      setState(() => guestsCount++);
                    }
                  },
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectTableSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Table',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
        const SizedBox(height: 24),
        _buildFloorPlan(),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Available', Colors.white.withOpacity(0.2)),
        _buildLegendItem('Booked', Colors.white.withOpacity(0.05)),
        _buildLegendItem('Selected', AppTheme.primaryPurple),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildFloorPlan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'STAGE',
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: List.generate(9, (index) {
              final tableId = 'T${index + 1}';
              return _buildTableWidget(tableId);
            }),
          ),
          const SizedBox(height: 40),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'BAR AREA',
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableWidget(String tableId) {
    final isBooked = bookedTables.contains(tableId);
    final isSelected = selectedTable == tableId;

    Color bgColor = Colors.white.withOpacity(0.2);
    if (isBooked) bgColor = Colors.white.withOpacity(0.05);
    if (isSelected) bgColor = AppTheme.primaryPurple;

    return GestureDetector(
      onTap: isBooked
          ? null
          : () {
              setState(() {
                if (selectedTable == tableId) {
                  selectedTable = null;
                } else {
                  selectedTable = tableId;
                }
              });
            },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            tableId,
            style: TextStyle(
              color: isBooked ? Colors.white24 : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showTableSuggestionDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.darkBackground,
        title: const Text(
          'No Table Selected',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'We suggest selecting a table to avoid being placed randomly. Would you like to pick one now or proceed with a random assignment?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Pick a Table',
              style: TextStyle(color: AppTheme.primaryPurple),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _confirmReservation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
            ),
            child: const Text(
              'Proceed Anyway',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReservation() async {
    try {
      final String bookingDate = _formatDate(selectedDate);
      final String bookingTime = _formatTime(selectedTime);
      final int tableNum = int.tryParse(selectedTable?.substring(1) ?? '0') ?? 0;

      final Map<String, dynamic> booking = {
        'clubName': club.name,
        'date': bookingDate,
        'time': bookingTime,
        'guests': guestsCount,
        'tableNumber': tableNum,
        'totalPrice': basePrice,
      };

      await MongoDBService.createBooking(booking);

      
      if (booking.containsKey('_id')) {
        final bookingId =
            booking['_id'].toString().replaceAll('ObjectId("', '').replaceAll('")', '');

        final String qrData = 'SWAVE-RES-$bookingId-${club.name}-$bookingDate';

        await MongoDBService.bookingsCollection!.update(
          mongo.where.id(booking['_id']),
          mongo.modify.set('qrData', qrData),
        );

        await AuthService.addBooking(bookingId);
      }

      Get.snackbar(
        'Success',
        selectedTable == null
            ? 'Reservation confirmed! A table will be assigned upon arrival.'
            : 'Reservation confirmed for $selectedTable!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primaryPurple,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutBack,
      );
    } catch (e) {
       Get.snackbar('Error', 'Failed to create reservation');
    }
  }
}
