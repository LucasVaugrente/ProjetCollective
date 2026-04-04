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
      final response = await http
          .get(Uri.parse('${AppConfig.effectiveApiUrl}/api/cours/$coursId'));
      if (response.statusCode == 200) {
        final courseData = jsonDecode(response.body);
        await _coursRepository.createOrUpdate(Cours.fromJson(courseData));
        await _coursRepository.markAsDownloaded(coursId);
        await getCours(ModuleSelectionne().moduleSelectionne.id);
      }
    } catch (e) {
      debugPrint("Erreur lors du téléchargement du cours : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Progression du module : chapitres terminés / chapitres téléchargés → [0.0, 1.0]
  Future<double> getProgressionModule(Module module) async {
    return await progressionUseCase.calculerProgressionModule(module.id!);
  }

  // Progression d'un cours : pages vues / pages totales → [0.0, 1.0]
  Future<double> getProgressionCours(Cours cours) async {
    return await progressionUseCase.calculerProgressionCours(cours.id!) / 100;
  }
}
