import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/auth_service.dart';
import '../app_routes.dart';

/// Auth middleware to protect routes
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = AuthService.instance;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // Check both local auth and firebase auth
    if (authService.currentUser == null && firebaseUser == null) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

/// Role-based middleware
class RoleMiddleware extends GetMiddleware {
  final List<String> allowedRoles;

  RoleMiddleware({required this.allowedRoles});

  @override
  RouteSettings? redirect(String? route) {
    final authService = AuthService.instance;
    final user = authService.currentUser;

    if (user == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (!allowedRoles.contains(user.role)) {
      if (user.isStudent) {
        return const RouteSettings(name: AppRoutes.studentHome);
      } else {
        return const RouteSettings(name: AppRoutes.teacherHome);
      }
    }

    return null;
  }
}
