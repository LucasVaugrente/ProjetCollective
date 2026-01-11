import 'package:flutter/material.dart';
import 'package:factoscope/logic/progression_use_case.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/models/module.dart';
import 'package:factoscope/repositories/cours_repository.dart';
import 'package:factoscope/ui/module_selectionne.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';

class ListCoursViewModel with ChangeNotifier {
  final progressionUseCase = ProgressionUseCase();
  final CoursRepository _coursRepository = CoursRepository();
  bool _isLoading = false;
  List<Cours> _cours = [];

  bool get isLoading => _isLoading;
  List<Cours> get cours => _cours;

  Future<void> getCours(int? idModule) async {
    if (idModule == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _cours = await _coursRepository.getCoursesByModuleId(idModule);
      ModuleSelectionne().updateListModule(_cours);
    } catch (e) {
      debugPrint("Erreur lors de la récupération des cours : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllCours() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cours = await _coursRepository.getAll();
    } catch (e) {
      debugPrint("Erreur lors de la récupération de tous les cours : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadCours(int coursId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('${AppConfig.apiBaseUrl}/api/cours/$coursId'));
      if (response.statusCode == 200) {
        final courseData = jsonDecode(response.body);

        await _coursRepository.createOrUpdate(Cours.fromJson(courseData));

        await _downloadMedias(courseData['id'], courseData['pages']);

        await getCours(ModuleSelectionne().moduleSelectionne.id);
      }
    } catch (e) {
      debugPrint("Erreur lors du téléchargement du cours : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _downloadMedias(int coursId, List<dynamic> pages) async {
    for (var page in pages) {
      for (var media in page['medias']) {
        final localPath = await _downloadMedia(media['url']);
        await _coursRepository.saveMediaForCourse(
          coursId,
          media['url'],
          localPath,
          media['type'],
          page['id'],
        );
      }
    }
  }

  Future<String> _downloadMedia(String url) async {
    return 'chemon/local';
  }

  // Calcule la progression d'un module
  Future<double> getProgressionModule(Module module) async {
    return await progressionUseCase.calculerProgressionCours(module.id!) / 100;
  }

  // Calcule la progression d'un cours
  Future<double> getProgressionCours(Cours cours) async {
    return await progressionUseCase.calculerProgressionCours(cours.id!) / 100;
  }
}
