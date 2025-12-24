import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../../../routes/app_routes.dart';

/// Student list view for teachers
class StudentListView extends StatelessWidget {
  const StudentListView({super.key});

  @override
  Widget build(BuildContext context) {
    final teacherController = Get.find<TeacherController>();
    final searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('students'.tr),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'search_students'.tr,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // Trigger search
              },
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (teacherController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (teacherController.students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'no_students_yet'.tr,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teacherController.students.length,
          itemBuilder: (context, index) {
            final student = teacherController.students[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(student.fullName[0].toUpperCase()),
                ),
                title: Text(student.fullName),
                subtitle: Text(student.email ?? student.username),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Get.toNamed('/student/${student.userId}');
                },
              ),
            );
          },
        );
      }),
    );
  }
}
