import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'student_home_view.dart';
import 'badges_view.dart';
import '../../quran/views/surah_selector_view.dart';
import '../../more/views/more_view.dart';
import '../../settings/views/settings_view.dart';

/// Main student view with bottom navigation
class StudentMainView extends StatefulWidget {
  const StudentMainView({super.key});

  @override
  State<StudentMainView> createState() => _StudentMainViewState();
}

class _StudentMainViewState extends State<StudentMainView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const StudentHomeView(),
    const SurahSelectorView(),
    const BadgesView(),
    const MoreView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'home'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book),
            label: 'quran'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_events),
            label: 'badges'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz),
            label: 'more'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'settings'.tr,
          ),
        ],
      ),
    );
  }
}
