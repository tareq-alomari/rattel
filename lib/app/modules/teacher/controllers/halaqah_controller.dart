import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/halaqah_model.dart';
import '../../../data/services/halaqah_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../views/halaqah_detail_view.dart';

class HalaqahController extends GetxController {
  final HalaqahService _halaqahService = HalaqahService.to;

  final RxList<Halaqah> halaqat = <Halaqah>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHalaqat();
  }

  Future<void> loadHalaqat() async {
    isLoading.value = true;
    try {
      // Get current teacher ID from auth service
      final teacherId =
          Get.find<AuthController>().currentUser.value?.userId ?? 0;
      if (teacherId == 0) {
        Get.snackbar('خطأ', 'لم يتم العثور على معرف المعلم');
        return;
      }
      halaqat.value = await _halaqahService.getTeacherHalaqat(teacherId);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل الحلقات: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createHalaqah({
    required String name,
    required String schedule,
    String? description,
  }) async {
    try {
      final teacherId =
          Get.find<AuthController>().currentUser.value?.userId ?? 0;
      if (teacherId == 0) {
        Get.snackbar('خطأ', 'لم يتم العثور على معرف المعلم');
        return;
      }

      final halaqah = Halaqah(
        name: name,
        teacherId: teacherId,
        schedule: schedule,
        description: description,
      );

      await _halaqahService.createHalaqah(halaqah);
      await loadHalaqat();
      Get.back();
      Get.snackbar('نجح', 'تم إنشاء الحلقة بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إنشاء الحلقة: $e');
    }
  }
}

class HalaqahListView extends GetView<HalaqahController> {
  const HalaqahListView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HalaqahController());

    return Scaffold(
      appBar: AppBar(title: Text('halaqat'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.halaqat.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.groups, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'no_halaqat'.tr,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showCreateDialog(context),
                  icon: const Icon(Icons.add),
                  label: Text('create_halaqah'.tr),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.halaqat.length,
          itemBuilder: (context, index) {
            final halaqah = controller.halaqat[index];
            return Card(
              key: ValueKey(halaqah.id ?? index),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.groups,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(
                  halaqah.name,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(halaqah.description ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.to(() => HalaqahDetailView(halaqah: halaqah));
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: Text('create_halaqah'.tr),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final scheduleController = TextEditingController();
    final descController = TextEditingController();

    Get.defaultDialog(
      title: 'create_halaqah'.tr,
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'halaqah_name'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: scheduleController,
              decoration: InputDecoration(
                labelText: 'schedule'.tr,
                hintText: 'مثال: الأحد والثلاثاء 4:00 م',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'description'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      textConfirm: 'create'.tr,
      textCancel: 'cancel'.tr,
      onConfirm: () {
        if (nameController.text.isNotEmpty) {
          controller.createHalaqah(
            name: nameController.text,
            schedule: scheduleController.text,
            description: descController.text,
          );
        }
      },
    );
  }
}
