import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/repositories/cours_repository.dart';
import 'package:factoscope/ui/cours_selectionne.dart';
import 'package:go_router/go_router.dart';

import 'api_service.dart';
import 'cours_disponibles_dialog.dart';

class AllCoursView extends StatefulWidget {
  const AllCoursView({super.key});

  @override
  State<AllCoursView> createState() => _AllCoursViewState();
}

class _AllCoursViewState extends State<AllCoursView> {
  final CoursRepository coursRepository = CoursRepository();
  List<Cours> coursList = [];
  bool isLoading = true;
  final ApiService _apiService = ApiService();
  bool _apiConnectee = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print("Initialisation de AllCoursView");
    }
    _verifierConnexionApi();
    _loadCours();
  }

  Future<void> _verifierConnexionApi() async {
    final connectee = await _apiService.testConnection();
    if (mounted) {
      setState(() {
        _apiConnectee = connectee;
      });
      if (kDebugMode) {
        print("API connectée: $_apiConnectee");
      }
    }
  }

  Future<void> _loadCours() async {
    try {
      if (kDebugMode) {
        print("Chargement des cours...");
      }
      final cours = await coursRepository.getAll();
      if (kDebugMode) {
        print("Nombre de cours chargés : ${cours.length}");
      }
      for (var c in cours) {
        if (kDebugMode) {
          print("Cours chargé : ${c.titre}");
        }
      }
      setState(() {
        coursList = cours;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print("Erreur lors du chargement des cours: $e");
      }
    }
  }

  void _afficherCoursDisponibles() {
    showDialog(
      context: context,
      builder: (context) => const CoursDisponiblesDialog(),
    ).then((_) {
      _loadCours();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("Construction de la vue AllCoursView");
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tous les Cours'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1.0),
        titleTextStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        actions: [
          // Bouton de rafraîchissement de la connexion API
          IconButton(
            icon: Icon(
              Icons.cloud,
              color: _apiConnectee ? Colors.green : Colors.grey,
            ),
            onPressed: _verifierConnexionApi,
            tooltip: _apiConnectee
                ? 'API connectée'
                : 'API non disponible - Cliquer pour réessayer',
          ),
        ],
      ),
      body: Column(
        children: [
          // Bouton de téléchargement en haut de la liste
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _apiConnectee ? _afficherCoursDisponibles : null,
                    icon: const Icon(Icons.cloud_download),
                    label: Text(
                      _apiConnectee
                          ? 'Télécharger des cours depuis le serveur'
                          : 'API non disponible',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _apiConnectee
                          ? const Color.fromARGB(255, 236, 187, 139)
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _verifierConnexionApi,
                  tooltip: 'Vérifier la connexion',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              ],
            ),
          ),

          // Divider pour séparer le bouton de la liste
          const Divider(height: 1),

          // Liste des cours
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : coursList.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun cours disponible',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  if (_apiConnectee) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _afficherCoursDisponibles,
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Télécharger des cours'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 236, 187, 139),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            )
                : ListView.builder(
              itemCount: coursList.length,
              itemBuilder: (context, index) {
                final cours = coursList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 236, 187, 139),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    title: Text(
                      cours.titre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: cours.contenu.isNotEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        cours.contenu,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                        : null,
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      CoursSelectionne.instance.setCours(cours);
                      GoRouter.of(context).go('/cours/${cours.id}');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}