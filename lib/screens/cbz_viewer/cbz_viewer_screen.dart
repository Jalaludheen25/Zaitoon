import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class CbzViewerScreen extends StatefulWidget {
  const CbzViewerScreen({super.key});

  @override
  State<CbzViewerScreen> createState() => _CbzViewerScreenState();
}

class _CbzViewerScreenState extends State<CbzViewerScreen> {
  List<Uint8List> _images = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCbzFile();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCbzFile() async {
    try {
      final ByteData data =
          await rootBundle.load('assets/images/Poocha_01_eng_001.cbz');
      final List<int> bytes = data.buffer.asUint8List();
      final archive = ZipDecoder().decodeBytes(bytes);

      final List<Uint8List> images = [];
      for (final file in archive) {
        if (file.isFile && _isImageFile(file.name)) {
          images.add(file.content as Uint8List);
        }
      }

      setState(() {
        _images = images;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading CBZ file: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isImageFile(String filename) {
    final lower = filename.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_images.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No images found in CBZ file'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CBZ Viewer'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        itemCount: _images.length,
        cacheExtent: 2000, // Increase cache to prevent rebuilding
        itemBuilder: (context, index) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Image.memory(
              _images[index],
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true, // Prevents flickering during scrolling
            ),
          );
        },
      ),
    );
  }
}
