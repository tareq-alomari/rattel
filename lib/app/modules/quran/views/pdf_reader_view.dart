import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

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
  // ignore: unused_field
  PdfViewerController? _controller;
  int _totalPages = 0;
  int _currentPage = 1;
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_ready)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: PdfViewer.asset(
        widget.assetPath,
        params: PdfViewerParams(
          onViewerReady: (document, controller) {
            setState(() {
              _totalPages = document.pages.length;
              _ready = true;
              _controller = controller;
            });
          },
          onPageChanged: (pageNumber) {
            setState(() {
              _currentPage = pageNumber ?? 1;
            });
          },
          errorBannerBuilder: (context, error, stackTrace, documentRef) {
            return Center(child: Text('Error: $error'));
          },
        ),
      ),
    );
  }
}
