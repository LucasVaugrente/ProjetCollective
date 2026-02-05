import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/repositories/cours_repository.dart';
import 'package:factoscope/ui/cours_selectionne.dart';
import 'package:go_router/go_router.dart';

class AllCoursView extends StatefulWidget {
  const AllCoursView({super.key});

  @override
  State<AllCoursView> createState() => _AllCoursViewState();
}

class _AllCoursViewState extends State<AllCoursView> {
  final CoursRepository coursRepository = CoursRepository();
  List<Cours> coursList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print("Initialisation de AllCoursView");
    }
    _loadCours();
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: coursList.length,
              itemBuilder: (context, index) {
                final cours = coursList[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(cours.titre),
                    subtitle: Text(cours.contenu),
                    onTap: () {
                      CoursSelectionne.instance.setCours(cours);
                      GoRouter.of(context).go('/cours/${cours.id}');
                    },
                  ),
                );
              },
            ),
    );
  }
}
