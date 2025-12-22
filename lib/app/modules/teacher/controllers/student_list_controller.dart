import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';

/// Student list controller
class StudentListController extends GetxController {
  final DatabaseService _dbService = DatabaseService.instance;

  final RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredStudents =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadStudents();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadStudents() async {
    try {
      isLoading.value = true;
      final result = await _dbService.getAllStudents();
      students.value = result;
      filteredStudents.value = result;
    } catch (e) {
      debugPrint('Error loading students: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterStudents(String query) {
    if (query.isEmpty) {
      filteredStudents.value = students;
      return;
    }

    filteredStudents.value = students.where((student) {
      final name = (student['name'] ?? '').toString().toLowerCase();
      final email = (student['email'] ?? '').toString().toLowerCase();
      final searchLower = query.toLowerCase();
      return name.contains(searchLower) || email.contains(searchLower);
    }).toList();
  }
}
