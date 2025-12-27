import 'package:get/get.dart';
import '../../../data/providers/database_helper.dart';
import '../../../data/models/memorization_models.dart';

class StudentDetailController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxMap<String, dynamic> student = <String, dynamic>{}.obs;
  final RxList<MemorizationPlan> studentPlans = <MemorizationPlan>[].obs;
  final RxList<DailyLog> recentLogs = <DailyLog>[].obs;

  @override
  void onInit() {
    super.onInit();
    final studentId = int.tryParse(Get.parameters['id'] ?? '');
    if (studentId != null) {
      loadStudentDetails(studentId);
    }
  }

  Future<void> loadStudentDetails(int studentId) async {
    isLoading.value = true;
    try {
      // 1. Fetch Student Info
      final user = await DatabaseHelper.instance.getUser(studentId);
      if (user != null) {
        student.value = user;
      }

      // 2. Fetch Plans (Need to filter by user_id, doing manually for now or add query)
      final allPlans = await DatabaseHelper.instance.getMemorizationPlans();
      studentPlans.value = allPlans
          .map((p) => MemorizationPlan.fromMap(p))
          .where((p) => p.userId == studentId)
          .toList();

      // 3. Fetch Logs (This is inefficient, better to query logs by plan IDs)
      // For MVP, just loading logs for the first active plan
      if (studentPlans.isNotEmpty) {
        final planId = studentPlans.first.id!;
        final logsData = await DatabaseHelper.instance.getDailyLogs(planId);
        recentLogs.value = logsData.map((l) => DailyLog.fromMap(l)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load details: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
