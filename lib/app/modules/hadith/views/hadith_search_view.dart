import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../hadith/controllers/hadith_controller.dart';
import '../../../data/models/hadith.dart';

class HadithSearchView extends GetView<HadithController> {
  const HadithSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final searchTextController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'search_hadith'.tr,
          style: GoogleFonts.cairo(),
        ), // Add translation later
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchTextController,
              decoration: InputDecoration(
                hintText: 'search_placeholder'.tr,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(
                  () => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchTextController.clear();
                            controller.clearSearch();
                          },
                        )
                      : const SizedBox(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => controller.search(value),
              textDirection: TextDirection.rtl,
            ),
          ),

          // Results
          Expanded(
            child: Obx(() {
              if (controller.isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.searchQuery.value.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.saved_search,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Start searching in Sunnah books',
                        style: GoogleFonts.cairo(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              if (controller.searchResults.isEmpty) {
                return Center(
                  child: Text(
                    'no_results_found'.tr,
                    style: GoogleFonts.cairo(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  return _buildResultCard(
                    context,
                    controller.searchResults[index],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, Hadith hadith) {
    // We can highlight the search term later
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          hadith.text,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.amiri(fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Book ID: ${hadith.bookId} | #${hadith.hadithNumber}',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                hadith.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                color: hadith.isFavorite
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              onPressed: () => controller.toggleFavorite(hadith),
            ),
            Obx(
              () => IconButton(
                icon: Icon(
                  controller.isMemorized(hadith.id!)
                      ? Icons.psychology
                      : Icons.psychology_outlined,
                  color: controller.isMemorized(hadith.id!)
                      ? Colors.green
                      : Colors.grey,
                ),
                onPressed: () => controller.toggleMemorization(hadith.id!),
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to Reader or just expand?
          // For MVP, maybe show a dialog or navigate to book view scrolled to item?
          // Showing full details in a dialog is easiest for search results.
          Get.defaultDialog(
            title: "Hadith #${hadith.hadithNumber}",
            titleStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            content: SizedBox(
              height: 400, // Fixed height or flexible
              width: Get.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      hadith.text,
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(fontSize: 18),
                    ),
                    const Divider(),
                    Text(
                      hadith.explanation,
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            cancel: TextButton(
              onPressed: () => Get.back(),
              child: const Text("Close"),
            ),
          );
        },
      ),
    );
  }
}
