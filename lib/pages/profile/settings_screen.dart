import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/theme.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Map<String, dynamic> _settings;

  @override
  void initState() {
    super.initState();
    _settings = Map<String, dynamic>.from(AuthService.currentUser?['settings'] ?? {
      'notifications': true,
      'locationServices': true,
      'darkMode': true,
      'soundEffects': false,
      'marketingEmails': false,
      'volume': 0.7,
      'brightness': 0.8,
    });
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    setState(() {
      _settings[key] = value;
    });
    await AuthService.updateSettings(_settings);
  }

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
                _buildToggleItem('Notifications', 'notifications'),
                _buildDivider(),
                _buildToggleItem('Location Services', 'locationServices'),
                _buildDivider(),
                _buildToggleItem('Dark Mode', 'darkMode'),
                _buildDivider(),
                _buildSliderItem('Volume', 'volume'),
                _buildDivider(),
                _buildSliderItem('Brightness', 'brightness'),
                _buildDivider(),
                _buildToggleItem('Sound Effects', 'soundEffects'),
                _buildDivider(),
                _buildToggleItem('Marketing Emails', 'marketingEmails'),
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

  Widget _buildToggleItem(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: _settings[key] ?? false,
            onChanged: (value) => _updateSetting(key, value),
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.primaryPurple,
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
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
              value: (_settings[key] as num?)?.toDouble() ?? 0.5,
              onChanged: (value) => _updateSetting(key, value),
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
