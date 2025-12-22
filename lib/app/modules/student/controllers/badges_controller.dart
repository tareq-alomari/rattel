import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/badge_model.dart';

/// Badges controller for student badges
class BadgesController extends GetxController {
  final DatabaseService _dbService = DatabaseService.instance;
  final AuthService _authService = AuthService.instance;

  final RxList<BadgeModel> allBadges = <BadgeModel>[].obs;
  final RxBool isLoading = false.obs;

  int get earnedCount => allBadges.where((b) => b.isEarned).length;
  int get totalCount => allBadges.length;

  @override
  void onInit() {
    super.onInit();
    loadBadges();
  }

  Future<void> loadBadges() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUser?.userId;
      if (userId != null) {
        allBadges.value = await _dbService.getUserBadges(userId);
      }
    } catch (e) {
      debugPrint('Error loading badges: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
