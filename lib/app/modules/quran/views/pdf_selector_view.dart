import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quran_controller.dart';
import 'pdf_reader_view.dart';

class PdfSelectorView extends GetView<QuranController> {
  const PdfSelectorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'quran_pdf'.tr,
        ), // Need to ensure translation exists or use fallback
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.pdfFiles.length,
        itemBuilder: (context, index) {
          final pdf = controller.pdfFiles[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(pdf['name'] ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.to(
                  () => PdfReaderView(
                    title: pdf['name'] ?? '',
                    assetPath: pdf['path'] ?? '',
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
