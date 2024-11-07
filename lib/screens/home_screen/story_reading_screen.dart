// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:d4tales/constants/color_class.dart';
import 'package:d4tales/helper/navigation_helper.dart';
import 'package:d4tales/screens/home_screen/home_screen.dart';
import 'package:d4tales/screens/home_screen/provider/story_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';

class PDFViewerScreen extends StatelessWidget {
  final String pdfUrl;

  const PDFViewerScreen({
    super.key,
    required this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PDFState(),
      child: PDFViewerContent(pdfUrl: pdfUrl),
    );
  }
}

class PDFViewerContent extends StatefulWidget {
  final String pdfUrl;

  const PDFViewerContent({
    super.key,
    required this.pdfUrl,
  });

  @override
  State<PDFViewerContent> createState() => _PDFViewerContentState();
}

class _PDFViewerContentState extends State<PDFViewerContent> {
  @override
  void initState() {
    super.initState();
    // Load PDF when screen initializes
    Future.microtask(() => context.read<PDFState>().loadPDF(widget.pdfUrl));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      navigatePRTo(context, const HomeScreen());
      return false; // Prevents default back navigation
    },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('PDF Viewer'),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
            navigatePRTo(context, const HomeScreen());
            },
          ),
          actions: [
            Consumer<PDFState>(
              builder: (context, state, child) {
                if (state.totalPages > 0) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Page ${state.currentPage + 1} of ${state.totalPages}',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Consumer<PDFState>(
          builder: (context, state, child) {
            if (state.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoActivityIndicator(
                      color: ColorClass.white,
                    ),
                    SizedBox(height: 16),
                    Text('Loading PDF...'),
                  ],
                ),
              );
            }
      
            if (state.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading PDF:\n${state.errorMessage}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PDFState>().loadPDF(widget.pdfUrl);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
      
            if (state.pdfPath == null) {
              return const Center(
                child: Text('No PDF loaded'),
              );
            }
      
            return PDFView(
              filePath: state.pdfPath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageSnap: true,
              onRender: (pages) {
                state.setTotalPages(pages!);
              },
              onPageChanged: (page, total) {
                state.setCurrentPage(page!);
              },
              onError: (error) {
                log('Error rendering PDF: $error');
              },
            );
          },
        ),
      ),
    );
  }
}

// main.dart or your app file