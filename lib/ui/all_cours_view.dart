import 'package:flutter/material.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/repositories/cours_repository.dart';
import 'package:go_router/go_router.dart';

class AllCoursView extends StatefulWidget {
  const AllCoursView({super.key});

  @override
  State<AllCoursView> createState() => _AllCoursViewState();
}

class _AllCoursViewState extends State<AllCoursView> {
  final CoursRepository coursRepository = CoursRepository();
  List<Cours> coursList = [];

  @override
  void initState() {
    super.initState();
    _loadCours();
  }

  Future<void> _loadCours() async {
    final cours = await coursRepository.getAll();
    setState(() {
      coursList = cours;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tous les Cours'),
      ),
      body: ListView.builder(
        itemCount: coursList.length,
        itemBuilder: (context, index) {
          final cours = coursList[index];
          return ListTile(
            title: Text(cours.titre),
            subtitle: Text(cours.contenu),
            onTap: () {
              GoRouter.of(context).go('/cours/$cours.id');
            },
          );
        },
      ),
    );
  }
}
