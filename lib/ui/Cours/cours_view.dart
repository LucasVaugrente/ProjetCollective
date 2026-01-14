import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:factoscope/ui/Cours/cours_view_model.dart';
import 'package:factoscope/ui/Description/description_view.dart';
import 'package:factoscope/ui/Contenu/contenu_cours_view.dart';
import 'package:factoscope/ui/cours_selectionne.dart';

import '../../models/cours.dart';
import '../../repositories/cours_repository.dart';

class CoursView extends StatefulWidget {
  final int coursId;

  const CoursView({super.key, required this.coursId});

  @override
  State<CoursView> createState() => _CoursViewState();
}

class _CoursViewState extends State<CoursView> {
  final coursViewModel = CoursViewModel();
  Widget? child;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCours();
  }

  Future<void> _loadCours() async {
    try {
      final coursRepository = CoursRepository();
      final loadedCours = await coursRepository.getById(widget.coursId);
      if (loadedCours != null) {
        CoursSelectionne.instance.setCours(loadedCours);
        await coursViewModel.loadContenu(loadedCours);
        await coursViewModel.setIndexPageVisite(loadedCours);
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors du chargement du cours: $e");
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ListenableBuilder(
      listenable: coursViewModel,
      builder: (context, _) {
        return _buildCoursView(context);
      },
    );
  }

  Widget _buildCoursView(BuildContext context) {
    CoursSelectionne coursSelectionne = CoursSelectionne.instance;
    int nbPageCours = coursSelectionne.cours.pages?.length ?? 0;
    int currentPage = coursViewModel.page;

    Widget nouvellePage =
    const Text("PB lors du chargement de la page de cours");
    if (currentPage == 0) {
      nouvellePage = DescriptionView(
          cours: coursSelectionne.cours, coursViewModel: coursViewModel);
    } else if (currentPage <= nbPageCours) {
      nouvellePage = ContenuCoursView(
          cours: coursSelectionne.cours, selectedPageIndex: currentPage - 1);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: FutureBuilder(
          future: coursViewModel.getProgressionActuelle(coursSelectionne.cours),
          builder: (context, snapshot) {
            return HeaderWidget(
              cours: coursSelectionne.cours,
              progression: snapshot.data,
            );
          },
        ),
        centerTitle: false,
      ),
      body: nouvellePage,
      bottomNavigationBar: nouvellePage.runtimeType != DescriptionView
          ? FooterWidget(
        courseTitle: coursSelectionne.cours.titre,
        pageNumber: currentPage,
        coursViewModel: coursViewModel,
      )
          : null,
    );
  }
}

class HeaderWidget extends StatelessWidget {
  final Cours cours;
  final double? progression;

  const HeaderWidget({
    super.key,
    required this.cours,
    this.progression,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(width: 8),
        Text(
          cours.titre,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (progression != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progression,
              minHeight: 6,
              color: Colors.teal,
              backgroundColor: Colors.teal.withOpacity(0.2),
            ),
          ),
      ],
    );
  }
}

class FooterWidget extends StatelessWidget {
  final String courseTitle;
  final int pageNumber;
  final CoursViewModel coursViewModel;

  const FooterWidget({
    super.key,
    required this.courseTitle,
    required this.pageNumber,
    required this.coursViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left, size: 28),
            onPressed: () {
              coursViewModel.changementPagePrecedente();
            },
          ),
          Text(
            '$courseTitle : Page $pageNumber',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right, size: 28),
            onPressed: () {
              coursViewModel.changementPageSuivante();
            },
          ),
        ],
      ),
    );
  }
}