import 'package:flutter/material.dart';

import 'package:flutter_pdfview/flutter_pdfview.dart';

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class PdfReaderView extends StatefulWidget {
  final String title;
  final String assetPath;

  const PdfReaderView({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  State<PdfReaderView> createState() => _PdfReaderViewState();
}

class _PdfReaderViewState extends State<PdfReaderView> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _ready = false;
  String _errorMessage = '';
  String? _localPath;

  // ignore: unused_field
  late PDFViewController _pdfViewController;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    try {
      final file = await _fromAsset(
        widget.assetPath,
        widget.assetPath.split('/').last,
      );
      setState(() {
        _localPath = file.path;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<File> _fromAsset(String asset, String filename) async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      var file = File('${dir.path}/$filename');
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localPath == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_ready)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: _localPath,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: _currentPage,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            // Since we are loading from assets, we might need to copy to temp file first?
            // flutter_pdfview usually requires a file path on device, not asset path directly.
            // Wait, does it support assets?
            // Re-checking documentation implies 'filePath' usually, but 'fromAsset' param exists in some versions?
            // If checking fails, we might need to copy file.
            // But let's check basic usage first. If 'filePath' supports assets, great.
            // Actually, flutter_pdfview usually needs a local file.
            // I will implement a loader to copy asset to temp.
            onRender: (pages) {
              setState(() {
                _totalPages = pages!;
                _ready = true;
              });
            },
            onError: (error) {
              setState(() {
                _errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                _errorMessage = '$page: ${error.toString()}';
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _pdfViewController = pdfViewController;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page!;
              });
            },
          ),
          if (!_ready && _errorMessage.isEmpty)
            const Center(child: CircularProgressIndicator()),
          if (_errorMessage.isNotEmpty) Center(child: Text(_errorMessage)),
        ],
      ),
    );
  }
}
