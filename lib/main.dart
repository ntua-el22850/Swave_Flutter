import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/mongodb_service.dart';
import 'services/navigation_controller.dart';
import 'utils/theme.dart';
import 'services/mock_data_service.dart';
import 'services/auth_middleware.dart';
import 'routes/app_routes.dart';
import 'pages/main_navigation_screen.dart';
import 'pages/auth/login_screen.dart';
import 'pages/auth/signup_screen.dart';
import 'pages/clubs/club_detail_screen.dart';
import 'pages/events/event_detail_screen.dart';
import 'pages/clubs/reservation_screen.dart';
import 'pages/profile/bookings_history_screen.dart';
import 'pages/profile/friends_list_screen.dart';
import 'pages/profile/user_detail_screen.dart';
import 'pages/profile/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await MongoDBService.connect();

  Get.put(NavigationController());
  runApp(
    MultiProvider(
      providers: [
        Provider<MockDataService>(create: (_) => MockDataService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swave',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Initial page
      initialRoute: AppRoutes.login,

      // Default transitions
      defaultTransition: Transition.rightToLeftWithFade,
      
      // All app routes
      getPages: [
        // Auth Routes
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: AppRoutes.signup,
          page: () => const SignupScreen(),
        ),

        // Protected Main Shell
        GetPage(
          name: AppRoutes.main,
          page: () => const MainNavigationScreen(),
          middlewares: [AuthMiddleware()],
          transition: Transition.fadeIn,
        ),

        // Detail screens - Modal style transitions
        GetPage(
          name: AppRoutes.clubDetail,
          page: () => const ClubDetailScreen(),
          fullscreenDialog: true,
          transition: Transition.cupertinoDialog,
        ),
        GetPage(
          name: AppRoutes.eventDetail,
          page: () => const EventDetailScreen(),
          fullscreenDialog: true,
          transition: Transition.cupertinoDialog,
        ),
        GetPage(
          name: AppRoutes.reservation,
          page: () => const ReservationScreen(),
          fullscreenDialog: true,
          transition: Transition.cupertinoDialog,
        ),
        GetPage(
          name: AppRoutes.userDetail,
          page: () => const UserDetailScreen(),
          fullscreenDialog: true,
          transition: Transition.cupertinoDialog,
        ),

        // Sub-screens
        GetPage(
          name: AppRoutes.bookingsHistory,
          page: () => const BookingsHistoryScreen(),
        ),
        GetPage(
          name: AppRoutes.friendsList,
          page: () => const FriendsListScreen(),
        ),
        GetPage(
          name: AppRoutes.settings,
          page: () => const SettingsScreen(),
        ),
      ],
    );
  }
}
