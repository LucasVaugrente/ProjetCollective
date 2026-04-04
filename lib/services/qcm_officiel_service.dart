import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';
import '../models/QCM/qcm.dart';
import '../repositories/QCM/qcm_repository.dart';
import '../ui/api_service.dart';

const int kCoursOfficielDistantId = kCoursOfficielId;

const String kQCMOfficielSynced = 'qcm_officiel_synced';

class QCMOfficielService {
  static final QCMOfficielService _instance = QCMOfficielService._internal();
  factory QCMOfficielService() => _instance;
  QCMOfficielService._internal();

  final QCMRepository _qcmRepository = QCMRepository();

  Future<void> syncIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dejaSynced = prefs.getBool(kQCMOfficielSynced) ?? false;
      final questionsEnLocal =
          await _qcmRepository.getAllByCoursId(kCoursOfficielDistantId);
      if (dejaSynced && questionsEnLocal.isNotEmpty) return;

      if (kDebugMode) print('📥 Téléchargement du QCM officiel...');

      final response = await http.get(
        Uri.parse(
            '${AppConfig.effectiveApiUrl}/api/qcm/$kCoursOfficielDistantId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      final List<dynamic> data = json.decode(response.body);
      if (data.isEmpty) {
        if (kDebugMode) print('⚠️ QCM officiel vide');
        return;
      }

      await _qcmRepository.deleteByCoursId(kCoursOfficielDistantId);

      for (final jsonItem in data) {
        await _qcmRepository.insert(QCM(
          question: jsonItem['question']?.toString() ?? '',
          rep1: jsonItem['rep1']?.toString() ?? '',
          rep2: jsonItem['rep2']?.toString() ?? '',
          rep3: jsonItem['rep3']?.toString() ?? '',
          rep4: jsonItem['rep4']?.toString() ?? '',
          soluce: ((jsonItem['soluce'] as int?) ?? 1) - 1,
          idCours: kCoursOfficielDistantId,
        ));
      }

      await prefs.setBool(kQCMOfficielSynced, true);
    } catch (e) {
      if (kDebugMode) print('⚠️ Erreur sync QCM officiel: $e');
    }
  }

  Future<void> resetSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kQCMOfficielSynced);
    await _qcmRepository.deleteByCoursId(kCoursOfficielDistantId);
    if (kDebugMode) print('🔄 Sync QCM officiel réinitialisée');
  }
}
