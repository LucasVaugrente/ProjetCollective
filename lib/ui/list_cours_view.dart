import 'package:flutter/material.dart';
import 'package:factoscope/models/list_cours_view_model.dart';
import 'package:factoscope/ui/cours_selectionne.dart';

import '../models/cours.dart';
import '../models/module.dart';
import 'module_selectionne.dart';

import 'package:go_router/go_router.dart';

class ListCoursView extends StatefulWidget {
  final ListCoursViewModel listCours = ListCoursViewModel();
  final ModuleSelectionne moduleSelectionne = ModuleSelectionne();

  ListCoursView({super.key});

  @override
  State<ListCoursView> createState() => ListCoursViewState();
}

class ListCoursViewState extends State<ListCoursView> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.moduleSelectionne,
        builder: (context, child) {
          int size = 0;
          Module module = widget.moduleSelectionne.moduleSelectionne;
          widget.listCours.getCours(module.id);
          size = widget.moduleSelectionne.coursDuModule.length;

          return ListenableBuilder(
              listenable: widget.listCours,
              builder: (context, child) {
                return Column(
                  children: [
                    FutureBuilder(
                        future:
                            ListCoursViewModel().getProgressionModule(module),
                        builder: (context, snapshot) {
                          return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 20.0),
                              child: moduleHeader(module, snapshot.data));
                        }),
                    Expanded(
                      child: ListView.builder(
                        itemCount: size + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5.0),
                                  child: const Text(
                                    "Description et Objectif du Module",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    module.description,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Divider(
                                              color: Colors.grey[300],
                                              thickness: 1)),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Text(
                                          "Chapitres",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child: Divider(
                                              color: Colors.grey[300],
                                              thickness: 1)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            );
                          } else {
                            final item = widget
                                .moduleSelectionne.coursDuModule[index - 1];
                            return listItem(item, context);
                          }
                        },
                      ),
                    ),
                  ],
                );
              });
        });
  }
}

// Palette de dégradés — un par module (cycle si plus de 5 modules)
const List<List<Color>> _moduleGradients = [
  [Color(0xFFF7971E), Color(0xFFFFD200)], // orange → jaune
  [Color(0xFF56CCF2), Color(0xFF2F80ED)], // bleu ciel → bleu
  [Color(0xFF6FCF97), Color(0xFF219653)], // vert clair → vert
  [Color(0xFFEB5757), Color(0xFFF2994A)], // rouge → orange
  [Color(0xFF9B51E0), Color(0xFF56CCF2)], // violet → bleu
];

// Widget correspondant au titre du module
SizedBox moduleHeader(Module module, double? progress) {
  final gradient = _moduleGradients[(module.id! - 1) % _moduleGradients.length];

  return SizedBox(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            module.titre,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: Colors.white,
              backgroundColor: Colors.white38,
            ),
          ),
        ],
      ),
    ),
  );
}

// Widget permettant d'afficher et de sélectionner un cours
SizedBox listItem(Cours cours, BuildContext context) {
  return SizedBox(
    child: InkWell(
      onTap: () {
        CoursSelectionne.instance.setCours(cours);
        GoRouter.of(context).go('/cours/${cours.id}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
        child: FutureBuilder(
          future: ListCoursViewModel().getProgressionCours(cours),
          builder: (context, snapshot) {
            final double? progression = snapshot.data;
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color.fromARGB(255, 235, 235, 235),
              ),
              child: Row(
                children: [
                  // Icône du cours
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 236, 187, 139),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.school, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  // Titre + barre de progression
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cours.titre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (cours.contenu.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            cours.contenu,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54),
                          ),
                        ],
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progression ?? 0.0,
                            minHeight: 5,
                            color: const Color.fromARGB(255, 90, 230, 220),
                            backgroundColor:
                                const Color.fromARGB(255, 175, 240, 235),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}
