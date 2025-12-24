import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_main_controller.dart';
import 'teacher_home_view.dart';
import 'student_list_view.dart';
import 'teacher_settings_view.dart';
import '../../quran/views/surah_selector_view.dart';
import '../../more/views/more_view.dart';

/// Main teacher view with bottom navigation
class TeacherMainView extends StatelessWidget {
  const TeacherMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeacherMainController());

    final List<Widget> pages = [
      const TeacherHomeView(),
      const SurahSelectorView(),
      const StudentListView(),
      const MoreView(),
      const TeacherSettingsView(),
    ];

    return Scaffold(
      body: Obx(() => pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard),
              label: 'dashboard'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book),
              label: 'quran'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people),
              label: 'students'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view),
              label: 'more'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: 'settings'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
