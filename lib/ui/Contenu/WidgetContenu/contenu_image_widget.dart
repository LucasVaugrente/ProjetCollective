import 'package:flutter/material.dart';
import 'package:factoscope/models/media_cours.dart';
import 'package:factoscope/ui/Contenu/contenu_cours_view_model.dart';

class ContenuImageWidget extends StatelessWidget {
  final MediaCours media;
  final double width; 
  final double height; 
  final ContenuCoursViewModel viewModel = ContenuCoursViewModel(); 

  ContenuImageWidget({
    super.key,
    required this.media,
    this.width = 200,  // Valeur par défaut
    this.height = 200, // Valeur par défaut
  });

  @override
  Widget build(BuildContext context) {
    String? imagePath = viewModel.imageLoader(media);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0), // Padding léger
      child: imagePath != null
          ? Image.asset(
              imagePath,
              width: width,  // Largeur de l'image
              height: height, // Hauteur de l'image
              fit: BoxFit.cover,
              semanticLabel: media.caption, // Accessibilité
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
              },
            )
          : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
    );
  }
}
