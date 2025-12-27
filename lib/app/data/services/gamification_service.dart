import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'database_service.dart';
import '../models/badge_model.dart';

class GamificationService extends GetxService {
  static GamificationService get to => Get.find();

  final DatabaseService _db = DatabaseService.instance;

  final RxInt currentPoints = 0.obs;
  final RxList<BadgeModel> earnedBadges = <BadgeModel>[].obs;
  final RxList<BadgeModel> allBadges = <BadgeModel>[].obs;

  Future<GamificationService> init() async {
    await loadUserData(1);
    return this;
  }

  Future<void> loadUserData(int userId) async {
    currentPoints.value = await _db.getUserPoints(userId);
    allBadges.value = await _db.getAllBadges(userId);
    earnedBadges.value = allBadges.where((b) => b.isEarned).toList();
  }

  Future<void> awardPoints({
    required int amount,
    required String reason,
    int userId = 1,
  }) async {
    final newPoints = await _db.addPoints(userId, amount);
    currentPoints.value = newPoints;

    Get.snackbar(
      'Points Earned!',
      '+$amount Points: $reason',
      icon: const Icon(Icons.stars, color: Colors.amber),
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );

    // Check for badge qualifications after getting points
    checkBadges(userId);
  }

  Future<void> checkBadges(int userId) async {
    // 1. Refresh badge list to see current status
    final badges = await _db.getAllBadges(userId);

    for (var badge in badges) {
      if (badge.isEarned) continue; // Already earned

      bool earned = false;

      // Check validation logic based on criteriaType
      if (badge.criteriaType == 'total_verses') {
        final total = await _db.getTotalVersesMemorized(userId);
        if (total >= (badge.criteriaValue ?? 0)) earned = true;
      } else if (badge.criteriaType == 'streak_days') {
        final streak = await _db.getCurrentStreak(userId);
        if (streak >= (badge.criteriaValue ?? 0)) earned = true;
      }
      // Add more cases (surah_complete, etc.) here

      if (earned && badge.badgeId != null) {
        await _db.awardBadge(userId, badge.badgeId!);
        _showBadgeEarnedDialog(badge);
      }
    }

    // Refresh local lists
    loadUserData(userId);
  }

  void _showBadgeEarnedDialog(BadgeModel badge) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.military_tech, size: 80, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'New Badge Unlocked!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                badge.badgeName,
                style: const TextStyle(fontSize: 18, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              Text(
                badge.description ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Awesome!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
