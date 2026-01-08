import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routes/app_routes.dart';
import 'pages/home/home_screen.dart';
import 'pages/second/second_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swave',

      // Initial page
      initialRoute: AppRoutes.counter,

      // All app routes
      getPages: [
        GetPage(
          name: AppRoutes.counter,
          page: () => CounterScreen(),
        ),
        GetPage(
          name: AppRoutes.second,
          page: () => const SecondScreen(),
        ),
      ],
    );
  }
}
