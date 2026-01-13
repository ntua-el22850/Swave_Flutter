import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  // Simple mock of auth state
  // In a real app, this would check a reactive auth service
  static bool isAuthenticated = false;

  @override
  RouteSettings? redirect(String? route) {
    if (!isAuthenticated) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
