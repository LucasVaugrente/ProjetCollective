import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/ui/Contenu/WidgetContenu/contenu_image_widget.dart';
import 'package:factoscope/ui/Contenu/WidgetContenu/contenu_text_widget.dart';
import 'package:factoscope/ui/Contenu/WidgetContenu/contenu_video_widget.dart';

class ContenuCoursView extends StatelessWidget {
  final Cours cours;
  final int selectedPageIndex;

  const ContenuCoursView({
    super.key,
    required this.cours,
    required this.selectedPageIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (cours.pages == null ||
        selectedPageIndex < 0 ||
        selectedPageIndex >= cours.pages!.length) {
      if (kDebugMode) {
        print("Page introuvable");
      }
      return const Center(child: Text("Page introuvable"));
    }

    var page = cours.pages![selectedPageIndex];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Affichage de la description de la page
          if (page.description != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                page.description!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          // Affichage des médias
          if (page.medias != null && page.medias!.isNotEmpty)
            ...page.medias!.map((media) {
              if (kDebugMode) {
                print("Media url: ${media.url}, type: ${media.type}");
              }

              if (media.type == "image") {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ContenuImageWidget(media: media),
                );
              } else if (media.type == "video") {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ContenuVideoWidget(data: media),
                );
              } else if (media.type == "text") {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ContenuTextWidget(filePath: media.url),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Le Media n'a pas le bon type !"),
                );
              }
            }),
          if (page.medias == null || page.medias!.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Aucun média disponible"),
            ),
        ],
      ),
    );
  }
}