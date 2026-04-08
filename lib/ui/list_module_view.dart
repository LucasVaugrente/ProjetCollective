import 'package:flutter/material.dart';
import 'package:factoscope/models/module.dart';
import 'package:factoscope/ui/module_selectionne.dart';
import 'package:go_router/go_router.dart';
import 'list_module_view_model.dart';

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
        return SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                // --- Section Accueil ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                      const SizedBox(height: 4),
                      const Text(
                        "Factoscope est un outil pédagogique conçu pour vous accompagner dans votre formation. Notre objectif est de vous donner les clés pour décrypter l'information au quotidien.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // --- Section Tableau de bord ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tableau de bord",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      headerAvancement(),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // --- Section Soutien ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      const Text(
                        "Avec le soutien de",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _partnerLogo('lib/assets/cfi.jpg'),
                          _partnerLogo('lib/assets/epjt.png'),
                          _partnerLogo('lib/assets/nothing2hide.jpg'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _partnerLogo(String assetPath) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Image.asset(
          assetPath,
          height: 60,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business, color: Colors.grey),
            );
          },
        ),
      ),
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

// Header affichant l'avancement global de l'utilisateur
Widget headerAvancement() {
  return FutureBuilder<int>(
    future: ListModuleViewModel().getProgressionGlobale(),
    builder: (context, snapshot) {
      final int pct = snapshot.data ?? 0;
      final double ratio = pct / 100.0;

      return Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color.fromRGBO(252, 179, 48, 1), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Votre Avancement",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "$pct%",
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF032F7A),
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 10,
                      color: const Color.fromRGBO(252, 179, 48, 1),
                      backgroundColor: const Color.fromRGBO(252, 179, 48, 0.15),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pct == 100
                  ? "Tous les chapitres terminés 🎉"
                  : pct == 0
                      ? "Commencez votre formation !"
                      : "Continuez comme ça, vous progressez !",
              style: const TextStyle(fontSize: 13, color: Colors.black45),
            ),
          ],
        ),
      );
    },
  );
}
