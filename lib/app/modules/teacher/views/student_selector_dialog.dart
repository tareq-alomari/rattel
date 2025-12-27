import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/database_helper.dart';

/// Student Selector Dialog
class StudentSelectorDialog extends StatefulWidget {
  final int halaqahId;
  final Function(int studentId) onStudentSelected;

  const StudentSelectorDialog({
    super.key,
    required this.halaqahId,
    required this.onStudentSelected,
  });

  @override
  State<StudentSelectorDialog> createState() => _StudentSelectorDialogState();
}

class _StudentSelectorDialogState extends State<StudentSelectorDialog> {
  List<Map<String, dynamic>> availableStudents = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool isLoading = true;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAvailableStudents();
    searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableStudents() async {
    setState(() => isLoading = true);
    try {
      // Get all students
      final allStudents = await DatabaseHelper.instance.getStudents();

      // Get students already in this halaqah
      final db = await DatabaseHelper.instance.database;
      final existingStudents = await db.query(
        'halaqah_students',
        where: 'halaqah_id = ? AND status = ?',
        whereArgs: [widget.halaqahId, 'active'],
      );

      final existingIds = existingStudents.map((s) => s['student_id']).toSet();

      // Filter out students already in halaqah
      final available = allStudents
          .where((s) => !existingIds.contains(s['user_id']))
          .toList();

      setState(() {
        availableStudents = available;
        filteredStudents = available;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('خطأ', 'فشل تحميل الطلاب: $e');
    }
  }

  void _filterStudents() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredStudents = availableStudents.where((student) {
        final name = (student['name'] as String).toLowerCase();
        final email = (student['email'] as String).toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'اختر طالباً',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Field
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن طالب...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Students List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredStudents.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        return _buildStudentTile(student);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            searchController.text.isEmpty
                ? 'لا يوجد طلاب متاحون'
                : 'لم يتم العثور على نتائج',
            style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).primaryColor.withValues(alpha: 0.1),
          child: Icon(Icons.person, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          student['name'],
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(student['email']),
        trailing: ElevatedButton(
          onPressed: () {
            widget.onStudentSelected(student['user_id']);
            Get.back();
          },
          child: const Text('إضافة'),
        ),
      ),
    );
  }
}
