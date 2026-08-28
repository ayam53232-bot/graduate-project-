import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';

class ImageViewerScreen extends StatefulWidget {
  final String imageUrl;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
  });

  @override
  State<ImageViewerScreen> createState() =>
      _ImageViewerScreenState();
}

class _ImageViewerScreenState
    extends State<ImageViewerScreen> {
  bool isDownloading = false;

  Future<void> downloadImage() async {
    if (isDownloading) return;

    try {
      setState(() {
        isDownloading = true;
      });

      // Download image from URL
      final response = await http.get(
        Uri.parse(widget.imageUrl),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download image',
        );
      }

      final Uint8List imageBytes =
          response.bodyBytes;

      // Request permission if needed
      final hasAccess =
      await Gal.hasAccess();

      if (!hasAccess) {
        final granted =
        await Gal.requestAccess();

        if (!granted) {
          throw Exception(
            'Gallery permission denied',
          );
        }
      }

      // Save image to gallery
      await Gal.putImageBytes(
        imageBytes,
        album: 'Famous People',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image saved successfully!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Download failed: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,

        title: const Text(
          'Image Viewer',
        ),

        actions: [
          IconButton(
            tooltip: 'Download',
            onPressed: isDownloading
                ? null
                : downloadImage,

            icon: isDownloading
                ? const SizedBox(
              width: 22,
              height: 22,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(
              Icons.download,
            ),
          ),
        ],
      ),

      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,

          panEnabled: true,
          scaleEnabled: true,

          child: Image.network(
            widget.imageUrl,

            fit: BoxFit.contain,

            loadingBuilder: (
                context,
                child,
                loadingProgress,
                ) {
              if (loadingProgress == null) {
                return child;
              }

              return const Center(
                child:
                CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            },

            errorBuilder: (
                context,
                error,
                stackTrace,
                ) {
              return const Center(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.white,
                    ),

                    SizedBox(height: 15),

                    Text(
                      'Failed to load image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}