import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/bookmarks_controller.dart';
import '../controllers/quran_controller.dart';

class BookmarksView extends GetView<BookmarksController> {
  const BookmarksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('bookmarks'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('no_bookmarks'.tr),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = controller.bookmarks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.bookmark, color: Colors.brown),
                title: Text(
                  'Surah ${bookmark['surah']} - Ayah ${bookmark['ayah']}',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Page ${bookmark['page']} • ${bookmark['created_at'].substring(0, 10)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => controller.deleteBookmark(bookmark['id']),
                ),
                onTap: () {
                  // Navigate to Quran Reader
                  // For now, we'll try to find the QuranController and jump,
                  // or just go back with result if opened from there.
                  Get.back();
                  if (Get.isRegistered<QuranController>()) {
                    Get.find<QuranController>().jumpToPage(bookmark['page']);
                  }
                },
              ),
            );
          },
        );
      }),
    );
  }
}
