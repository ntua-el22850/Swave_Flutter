import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock states for settings
  final Map<String, bool> _toggles = {
    'Notifications': true,
    'Location Services': true,
    'Dark Mode': true,
    'Sound Effects': false,
    'Marketing Emails': false,
  };

  final Map<String, double> _sliders = {
    'Volume': 0.7,
    'Brightness': 0.8,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildToggleItem('Notifications'),
                _buildDivider(),
                _buildToggleItem('Location Services'),
                _buildDivider(),
                _buildToggleItem('Dark Mode'),
                _buildDivider(),
                _buildSliderItem('Volume'),
                _buildDivider(),
                _buildSliderItem('Brightness'),
                _buildDivider(),
                _buildToggleItem('Sound Effects'),
                _buildDivider(),
                _buildToggleItem('Marketing Emails'),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 30,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple,
            Color(0xFF4A3BB8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          const Expanded(
            child: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // To balance the back button
        ],
      ),
    );
  }

  Widget _buildToggleItem(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: _toggles[name] ?? false,
            onChanged: (value) {
              setState(() {
                _toggles[name] = value;
              });
            },
            activeColor: Colors.white,
            activeTrackColor: AppTheme.primaryPurple,
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryPurple,
              inactiveTrackColor: Colors.white10,
              thumbColor: Colors.white,
              overlayColor: AppTheme.primaryPurple.withOpacity(0.2),
            ),
            child: Slider(
              value: _sliders[name] ?? 0.5,
              onChanged: (value) {
                setState(() {
                  _sliders[name] = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.white10,
      thickness: 1,
      indent: 20,
      endIndent: 20,
    );
  }
}
