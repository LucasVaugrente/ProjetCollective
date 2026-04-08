import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';
import '../models/QCM/qcm.dart';
import '../repositories/QCM/qcm_repository.dart';

// Titre du cours fantôme côté BDD distante — seule constante à maintenir
const String kTitreCoursOfficiel = 'Test Officiel Factoscope';

// Clé SharedPreferences pour éviter de resync à chaque démarrage
const String kQCMOfficielSynced = 'qcm_officiel_synced';

// Clé pour mémoriser l'ID du cours officiel trouvé dynamiquement
const String kQCMOfficielCoursId = 'qcm_officiel_cours_id';

class QCMOfficielService {
  static final QCMOfficielService _instance = QCMOfficielService._internal();
  factory QCMOfficielService() => _instance;
  QCMOfficielService._internal();

  final QCMRepository _qcmRepository = QCMRepository();

  /// Retourne l'ID local du cours officiel (stocké en SharedPreferences)
  /// ou -1 si pas encore connu.
  Future<int> getCoursOfficielIdLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(kQCMOfficielCoursId) ?? -1;
  }

  /// Cherche l'ID du cours fantôme dans l'API par son titre.
  Future<int?> _trouverCoursOfficielDistant() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.effectiveApiUrl}/api/cours'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final List<dynamic> data = json.decode(response.body);
      for (final item in data) {
        final titre = item['titre']?.toString() ?? '';
        if (titre.trim().toLowerCase() ==
            kTitreCoursOfficiel.trim().toLowerCase()) {
          return item['id'] as int?;
        }
      }
      if (kDebugMode) {
        print(
            '⚠️ Cours officiel "$kTitreCoursOfficiel" introuvable dans l\'API');
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('⚠️ Erreur recherche cours officiel: $e');
      return null;
    }
  }

  /// À appeler au démarrage — télécharge le QCM officiel si pas encore en local.
  Future<void> syncIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dejaSynced = prefs.getBool(kQCMOfficielSynced) ?? false;

      // Récupérer l'ID mémorisé (ou -1 si inconnu)
      final idMemorise = prefs.getInt(kQCMOfficielCoursId) ?? -1;

      // Vérifier si les questions sont déjà en local
      if (dejaSynced && idMemorise != -1) {
        final questionsEnLocal =
            await _qcmRepository.getAllByCoursId(idMemorise);
        if (questionsEnLocal.isNotEmpty) return;
        if (kDebugMode) {
          print('⚠️ Flag sync présent mais BDD vide — resync forcée');
        }
      }

      if (kDebugMode) print('📥 Téléchargement du QCM officiel...');

      // Trouver l'ID du cours officiel dynamiquement
      final coursId = await _trouverCoursOfficielDistant();
      if (coursId == null) return;

      if (kDebugMode) print('   ID cours officiel trouvé: $coursId');

      final response = await http.get(
        Uri.parse('${AppConfig.effectiveApiUrl}/api/qcm/$coursId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('⚠️ QCM officiel indisponible (${response.statusCode})');
        }
        return;
      }

      final List<dynamic> data = json.decode(response.body);
      if (data.isEmpty) {
        if (kDebugMode) print('⚠️ QCM officiel vide');
        return;
      }

      // Nettoyer les anciennes questions si l'ID a changé
      if (idMemorise != -1 && idMemorise != coursId) {
        await _qcmRepository.deleteByCoursId(idMemorise);
      }
      await _qcmRepository.deleteByCoursId(coursId);

      for (final jsonItem in data) {
        await _qcmRepository.insert(QCM(
          question: jsonItem['question']?.toString() ?? '',
          rep1: jsonItem['rep1']?.toString() ?? '',
          rep2: jsonItem['rep2']?.toString() ?? '',
          rep3: jsonItem['rep3']?.toString() ?? '',
          rep4: jsonItem['rep4']?.toString() ?? '',
          soluce: ((jsonItem['soluce'] as int?) ?? 1) -
              1, // API 1-based → local 0-based
          idCours: coursId,
        ));
      }

      // Mémoriser l'ID et le flag
      await prefs.setInt(kQCMOfficielCoursId, coursId);
      await prefs.setBool(kQCMOfficielSynced, true);

      if (kDebugMode) {
        print(
            '✅ QCM officiel synchronisé (${data.length} questions, cours id=$coursId)');
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Erreur sync QCM officiel: $e');
    }
  }

  /// Remet à zéro le flag de sync (force un re-téléchargement au prochain démarrage).
  Future<void> resetSync() async {
    final prefs = await SharedPreferences.getInstance();
    final idMemorise = prefs.getInt(kQCMOfficielCoursId) ?? -1;
    await prefs.remove(kQCMOfficielSynced);
    await prefs.remove(kQCMOfficielCoursId);
    if (idMemorise != -1) {
      await _qcmRepository.deleteByCoursId(idMemorise);
    }
    if (kDebugMode) print('🔄 Sync QCM officiel réinitialisée');
  }
}
