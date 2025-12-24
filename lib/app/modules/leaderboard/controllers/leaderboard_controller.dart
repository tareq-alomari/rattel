import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../auth/controllers/auth_controller.dart';

class LeaderboardController extends GetxController {
  final DatabaseService _dbService = DatabaseService.instance;
  final AuthController _authController = Get.find<AuthController>();

  final isLoading = true.obs;
  final leaderboard = <Map<String, dynamic>>[].obs;
  final currentUserRank = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    try {
      isLoading.value = true;
      final results = await _dbService.getLeaderboard();
      leaderboard.assignAll(results);

      // Calculate current user rank
      final userId = _authController.userId;
      if (userId != null) {
        final index = leaderboard.indexWhere(
          (user) => user['user_id'] == userId,
        );
        if (index != -1) {
          currentUserRank.value = index + 1;
        } else {
          // If not in top 10, we might want to fetch their specific rank separately
          // For now, we leave it as 0 (unranked in top list)
          currentUserRank.value = 0;
        }
      }
    } catch (e) {
      print('Error loading leaderboard: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
