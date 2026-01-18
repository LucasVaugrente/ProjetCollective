// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:factoscope/models/list_cours_view_model.dart';
import 'package:factoscope/models/page.dart';
import 'package:factoscope/ui/Contenu/WidgetContenu/contenu_image_widget.dart';
import 'package:factoscope/ui/Cours/cours_view.dart';
import 'package:factoscope/ui/cours_selectionne.dart';

import '../models/cours.dart';
import '../models/module.dart';
import 'module_selectionne.dart';

import 'package:go_router/go_router.dart';

class ListCoursView extends StatefulWidget {
  ListCoursViewModel listCours = ListCoursViewModel();
  ModuleSelectionne moduleSelectionne = ModuleSelectionne();

  ListCoursView({super.key});

  @override
  State<ListCoursView> createState() =>
      ListCoursViewState(listCours, moduleSelectionne);
}

class ListCoursViewState extends State<ListCoursView> {
  late ListCoursViewModel listCours;
  late ModuleSelectionne moduleSelectionne;

  ListCoursViewState(this.listCours, this.moduleSelectionne);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: moduleSelectionne,
        builder: (context, child) {
          int size = 0;
          Module module = moduleSelectionne.moduleSelectionne;
          listCours.getCours(module.id);
          size = moduleSelectionne.coursDuModule.length;

          return ListenableBuilder(
              listenable: listCours,
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
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
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
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
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
                                        textAlign: TextAlign.left,
                                      )),
                                ],
                              ),
                            );
                          } else {
                            final item =
                            moduleSelectionne.coursDuModule[index - 1];
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

// Widget correspondant au titre du module
SizedBox moduleHeader(Module module, double? progress) {
  MediaItem media = MediaItem(
    ordre: 1,
    url: module.urlImg,
    type: "image",
  );

  return SizedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(255, 236, 187, 139),
        ),
        child: Row(
          children: [
            ContenuImageWidget(
              media: media,
              width: 80,
              height: 80,
            ),
            const Spacer(),
            Column(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                  margin:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                  child: Text(
                    module.titre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.clip,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        color: const Color.fromARGB(255, 90, 230, 220),
                        backgroundColor:
                        const Color.fromARGB(255, 175, 240, 235),
                      )),
                )
              ],
            ),
            const Spacer()
          ],
        ),
      ));
}

// Widget permettant d'afficher et de sélectionner un cours
SizedBox listItem(Cours cours, BuildContext context) {
  return SizedBox(
    child: InkWell(
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: FutureBuilder(
              future: ListCoursViewModel().getProgressionCours(cours),
              builder: (context, snapshot) {
                return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color.fromARGB(255, 235, 235, 235),
                    ),
                    child: HeaderWidget(
                        cours: cours, progression: snapshot.data));
              }),
        ),
        onTap: () {
          CoursSelectionne.instance.cours = cours;
          GoRouter.of(context).go('/cours');
        }),
  );
}