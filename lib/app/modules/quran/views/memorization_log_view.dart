import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/badge_service.dart';
import '../../../data/models/memorization_model.dart';

/// Memorization log view for students to log their progress
class MemorizationLogView extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int totalVerses;

  const MemorizationLogView({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.totalVerses,
  });

  @override
  State<MemorizationLogView> createState() => _MemorizationLogViewState();
}

class _MemorizationLogViewState extends State<MemorizationLogView> {
  final DatabaseService _dbService = DatabaseService.instance;
  final AuthService _authService = AuthService.instance;

  int _fromAyah = 1;
  int _toAyah = 1;
  String _type = 'memorization';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _toAyah = widget.totalVerses > 10 ? 10 : widget.totalVerses;
  }

  Future<void> _saveMemorization() async {
    final userId = _authService.currentUser?.userId;
    if (userId == null) {
      Get.snackbar('خطأ', 'يجب تسجيل الدخول أولاً');
      return;
    }

    if (_fromAyah > _toAyah) {
      Get.snackbar('خطأ', 'رقم الآية الأولى يجب أن يكون أصغر من الأخيرة');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final memorization = MemorizationModel(
        userId: userId,
        surahNumber: widget.surahNumber,
        fromAyah: _fromAyah,
        toAyah: _toAyah,
        type: _type,
        date: DateTime.now().toIso8601String(),
      );

      await _dbService.addMemorization(memorization);

      // Check for badges
      await BadgeService.instance.checkAndAwardBadges(userId);

      Get.back();
      Get.snackbar(
        'تم بنجاح ✅',
        _type == 'memorization'
            ? 'تم تسجيل الحفظ: ${_toAyah - _fromAyah + 1} آيات'
            : 'تم تسجيل المراجعة: ${_toAyah - _fromAyah + 1} آيات',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في حفظ السجل');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('تسجيل الحفظ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Surah Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    widget.surahName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'عدد الآيات: ${widget.totalVerses}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Type Selection
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نوع النشاط',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _TypeButton(
                            label: 'حفظ جديد',
                            icon: Icons.book,
                            isSelected: _type == 'memorization',
                            onTap: () => setState(() => _type = 'memorization'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TypeButton(
                            label: 'مراجعة',
                            icon: Icons.refresh,
                            isSelected: _type == 'revision',
                            onTap: () => setState(() => _type = 'revision'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ayah Range Selection
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نطاق الآيات',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('من آية'),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                initialValue: _fromAyah,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: List.generate(
                                  widget.totalVerses,
                                  (index) => DropdownMenuItem(
                                    value: index + 1,
                                    child: Text('${index + 1}'),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _fromAyah = value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('إلى آية'),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                initialValue: _toAyah,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: List.generate(
                                  widget.totalVerses,
                                  (index) => DropdownMenuItem(
                                    value: index + 1,
                                    child: Text('${index + 1}'),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _toAyah = value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'عدد الآيات: ${_toAyah >= _fromAyah ? _toAyah - _fromAyah + 1 : 0}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveMemorization,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'حفظ السجل',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
