import 'package:get/get.dart';
import '../../../data/providers/database_helper.dart';

class StudentListController extends GetxController {
  final RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadStudents();
  }

  Future<void> loadStudents() async {
    isLoading.value = true;
    try {
      final data = await DatabaseHelper.instance.getStudents();
      students.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load students: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onStudentTapped(int id) {
    Get.toNamed('/student/$id');
  }
}
