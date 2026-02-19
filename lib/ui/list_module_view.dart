import 'package:flutter/material.dart';
import 'package:factoscope/models/module.dart';
import 'package:factoscope/ui/module_selectionne.dart';
import 'package:factoscope/models/list_module_view_model.dart';
import 'package:go_router/go_router.dart';

// Widget de la page d'accueil/Liste des modules
class ListModulesView extends StatefulWidget {
  const ListModulesView({super.key});

  @override
  State<ListModulesView> createState() => _ListModulesViewState();
}

// State du widget d'affichage de la liste des modules (page d'accueil)
class _ListModulesViewState extends State<ListModulesView> {
  ListModuleViewModel listModuleViewModel = ListModuleViewModel();

  @override
  void initState() {
    super.initState();
    listModuleViewModel
        .recupererModule(); // Charge les modules dès l'initialisation
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listModuleViewModel,
      builder: (context, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Accueil",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline, size: 30),
                    onPressed: () => context.push('/about'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: const Text(
                  "Tableau de bord",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            headerAvancement(), // Appel à headerAvancement

            const Divider(height: 1),

            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: const Text(
                  "Cours récemment vus :",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Widget représentant l'header d'un module dans la liste des modules
SizedBox listModuleItem(Module item, BuildContext context) {
  return SizedBox(
    child: InkWell(
      child: FutureBuilder(
        future: ListModuleViewModel().getProgressionModule(item),
        builder: (context, snapshot) {
          return moduleHeader(item, snapshot.data);
        },
      ),
      onTap: () {
        ModuleSelectionne.instance.moduleSelectionne = item;
        GoRouter.of(context).push('/list_cours');
      },
    ),
  );
}

SizedBox moduleHeader(Module module, double? progress) {
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
          // Image du module
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              module.urlImg,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 40),
                );
              },
            ),
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
                    backgroundColor: const Color.fromARGB(255, 175, 240, 235),
                  ),
                ),
              )
            ],
          ),
          const Spacer()
        ],
      ),
    ),
  );
}

// Header affichant l'avancement dans le cours de l'utilisateur
SizedBox headerAvancement() {
  return SizedBox(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(255, 219, 218, 215),
      ),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            child: const Column(
              children: [
                Text(
                  "Votre Avancement",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.bookmark,
                size: 140,
                color: Color.fromARGB(255, 3, 47, 122),
              ),
              FutureBuilder(
                future: ListModuleViewModel().getProgressionGlobale(),
                builder: (context, snapshot) {
                  String progress = "";
                  if (snapshot.hasData) {
                    progress = snapshot.data.toString();
                  }

                  return Text(
                    "$progress%",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
