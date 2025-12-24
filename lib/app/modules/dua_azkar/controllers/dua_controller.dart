import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/dua_model.dart';
// import '../../auth/controllers/auth_controller.dart'; // Uncomment when Auth is fully ready

class DuaController extends GetxController {
  final DatabaseService _dbService = DatabaseService.instance;

  final RxList<DuaModel> duas = <DuaModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<int, int> counters = <int, int>{}.obs; // duaId -> current count

  // Stats
  final RxInt dailyCount = 0.obs;
  final RxList<Map<String, dynamic>> weeklyStats = <Map<String, dynamic>>[].obs;

  // Helper to get userId - simplified for demo
  int get currentUserId {
    // In a real app, you'd get this from AuthController
    // return Get.find<AuthController>().userId ?? 1;
    return 1;
  }

  @override
  void onInit() {
    super.onInit();
    _seedDataIfNeeded();
    fetchStats();
  }

  Future<void> _seedDataIfNeeded() async {
    await _dbService.seedDuas();
  }

  Future<void> fetchStats() async {
    try {
      dailyCount.value = await _dbService.getDailyAzkarCount(currentUserId);
      weeklyStats.value = await _dbService.getWeeklyAzkarStats(currentUserId);
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  Future<void> loadDuasByCategory(String category) async {
    try {
      isLoading.value = true;
      final results = await _dbService.getDuasByCategory(category);
      if (results.isEmpty) {
        // Retry seed if empty (just in case)
        await _dbService.seedDuas();
        duas.value = await _dbService.getDuasByCategory(category);
      } else {
        duas.value = results;
      }

      // Reset counters
      counters.clear();
      for (var dua in duas) {
        if (dua.id != null) {
          counters[dua.id!] = 0;
        }
      }

      // Also stats refresh
      fetchStats();
    } catch (e) {
      debugPrint('Error loading duas: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> incrementCounter(int duaId, int targetCount) async {
    if (!counters.containsKey(duaId)) {
      counters[duaId] = 0;
    }

    if (counters[duaId]! < targetCount) {
      counters[duaId] = counters[duaId]! + 1;

      // Log progress to DB
      await _dbService.logAzkarProgress(currentUserId, duaId, 1);

      // Update local daily count
      dailyCount.value++;

      // Optional: haptic feedback or sound could be added here
      if (counters[duaId] == targetCount) {
        Get.snackbar(
          'success'.tr,
          'excellent_work'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      }
    }
  }

  void resetCounter(int duaId) {
    counters[duaId] = 0;
  }

  double getProgress(int duaId, int targetCount) {
    final current = counters[duaId] ?? 0;
    if (targetCount == 0) return 0.0;
    return current / targetCount;
  }
}
