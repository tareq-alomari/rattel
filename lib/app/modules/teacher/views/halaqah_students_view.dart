import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/halaqah_model.dart';
import '../../../data/services/halaqah_service.dart';
import 'student_selector_dialog.dart';

/// Halaqah Students Management View
class HalaqahStudentsView extends StatefulWidget {
  final Halaqah halaqah;

  const HalaqahStudentsView({super.key, required this.halaqah});

  @override
  State<HalaqahStudentsView> createState() => _HalaqahStudentsViewState();
}

class _HalaqahStudentsViewState extends State<HalaqahStudentsView> {
  final HalaqahService _service = HalaqahService.to;
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => isLoading = true);
    try {
      final data = await _service.getHalaqahStudents(widget.halaqah.id!);
      setState(() {
        students = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('خطأ', 'فشل تحميل الطلاب: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('طلاب ${widget.halaqah.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddStudentDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadStudents,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return _buildStudentCard(student);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا يوجد طلاب في هذه الحلقة',
            style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddStudentDialog,
            icon: const Icon(Icons.person_add),
            label: const Text('إضافة طالب'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final joinedAt = DateTime.tryParse(student['joined_at'] ?? '');
    final joinedText = joinedAt != null
        ? 'انضم في ${joinedAt.day}/${joinedAt.month}/${joinedAt.year}'
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(Icons.person, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          student['name'] ?? 'غير معروف',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(joinedText),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.remove_circle, color: Colors.red),
                  SizedBox(width: 8),
                  Text('إزالة من الحلقة'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'remove') {
              _confirmRemoveStudent(student);
            }
          },
        ),
      ),
    );
  }

  void _showAddStudentDialog() {
    Get.dialog(
      StudentSelectorDialog(
        halaqahId: widget.halaqah.id!,
        onStudentSelected: (studentId) async {
          try {
            await _service.addStudentToHalaqah(widget.halaqah.id!, studentId);
            _loadStudents();
            Get.snackbar('تم', 'تم إضافة الطالب للحلقة');
          } catch (e) {
            Get.snackbar('خطأ', 'فشل إضافة الطالب: $e');
          }
        },
      ),
    );
  }

  void _confirmRemoveStudent(Map<String, dynamic> student) {
    Get.defaultDialog(
      title: 'تأكيد الإزالة',
      middleText: 'هل تريد إزالة ${student['name']} من الحلقة؟',
      textConfirm: 'إزالة',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        try {
          await _service.removeStudentFromHalaqah(
            widget.halaqah.id!,
            student['user_id'],
          );
          Get.back();
          _loadStudents();
          Get.snackbar('تم', 'تم إزالة الطالب من الحلقة');
        } catch (e) {
          Get.snackbar('خطأ', 'فشل إزالة الطالب: $e');
        }
      },
    );
  }
}
