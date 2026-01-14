import 'package:flutter/material.dart';
import 'package:factoscope/models/page.dart';

class ContenuImageWidget extends StatelessWidget {
  final MediaItem media;
  final double width;
  final double height;

  const ContenuImageWidget({
    super.key,
    required this.media,
    this.width = 200,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          Image.asset(
            media.url,
            width: width,
            height: height,
            fit: BoxFit.cover,
            semanticLabel: media.caption,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
            },
          ),
          if (media.caption != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                media.caption!,
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}