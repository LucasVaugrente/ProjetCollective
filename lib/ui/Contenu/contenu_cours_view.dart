import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/ui/Contenu/WidgetContenu/contenu_image_widget.dart';
import 'package:factoscope/ui/Contenu/WidgetContenu/contenu_video_widget.dart';
import 'package:factoscope/ui/Contenu/WidgetContenu/contenu_text_widget.dart';

class ContenuCoursView extends StatelessWidget {
  final Cours cours;
  final int selectedPageIndex;

  const ContenuCoursView({
    super.key,
    required this.cours,
    required this.selectedPageIndex,
  });

  @override
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
        children: page.medias?.map((media) {
              if (kDebugMode) {
                print("Media url: ${media.url}");
              }

              if (media.type == "image") {
                return Center(child: ContenuImageWidget(media: media));
              } else if (media.type == "video") {
                return ContenuVideoWidget(data: media);
              } else if (media.type == "text") {
                return ContenuTextWidget(filePath: media.url);
              } else {
                return const Text("Le Media n'a pas le bon type !");
              }
            }).toList() ??
            [const Text("Aucun média disponible")],
      ),
    );
  }
}
