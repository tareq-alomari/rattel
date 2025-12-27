import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/halaqah_model.dart';
import '../../../data/services/halaqah_service.dart';

/// Halaqah Sessions Management View
class HalaqahSessionsView extends StatefulWidget {
  final Halaqah halaqah;

  const HalaqahSessionsView({super.key, required this.halaqah});

  @override
  State<HalaqahSessionsView> createState() => _HalaqahSessionsViewState();
}

class _HalaqahSessionsViewState extends State<HalaqahSessionsView> {
  final HalaqahService _service = HalaqahService.to;
  List<HalaqahSession> sessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => isLoading = true);
    try {
      final data = await _service.getHalaqahSessions(widget.halaqah.id!);
      setState(() {
        sessions = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('خطأ', 'فشل تحميل الجلسات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جلسات ${widget.halaqah.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateSessionDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sessions.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadSessions,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return _buildSessionCard(session);
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
          Icon(Icons.event_note, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد جلسات مسجلة',
            style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateSessionDialog,
            icon: const Icon(Icons.add),
            label: const Text('إنشاء جلسة جديدة'),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(HalaqahSession session) {
    final dateText =
        '${session.date.day}/${session.date.month}/${session.date.year}';
    final attendanceCount = session.attendedStudentIds?.length ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.event, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          session.topic ?? 'جلسة $dateText',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$attendanceCount طالب حضر • $dateText'),
        children: [
          if (session.notes != null && session.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الملاحظات:',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(session.notes!),
                ],
              ),
            ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showSessionDetails(session),
                icon: const Icon(Icons.visibility),
                label: const Text('التفاصيل'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateSessionDialog() {
    final topicController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('إنشاء جلسة جديدة'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: topicController,
                    decoration: const InputDecoration(
                      labelText: 'موضوع الجلسة',
                      prefixIcon: Icon(Icons.topic),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('التاريخ'),
                    subtitle: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات',
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (topicController.text.isEmpty) {
                    Get.snackbar('خطأ', 'يرجى إدخال موضوع الجلسة');
                    return;
                  }

                  final session = HalaqahSession(
                    halaqahId: widget.halaqah.id!,
                    date: selectedDate,
                    topic: topicController.text,
                    notes: notesController.text,
                  );

                  try {
                    await _service.createSession(session);
                    Get.back();
                    _loadSessions();
                    Get.snackbar('تم', 'تم إنشاء الجلسة بنجاح');
                  } catch (e) {
                    Get.snackbar('خطأ', 'فشل إنشاء الجلسة: $e');
                  }
                },
                child: const Text('إنشاء'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSessionDetails(HalaqahSession session) {
    Get.dialog(
      AlertDialog(
        title: Text(session.topic ?? 'تفاصيل الجلسة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'التاريخ',
              '${session.date.day}/${session.date.month}/${session.date.year}',
            ),
            if (session.notes != null)
              _buildDetailRow('الملاحظات', session.notes!),
            _buildDetailRow(
              'الحضور',
              '${session.attendedStudentIds?.length ?? 0} طالب',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
