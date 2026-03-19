import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<List<CoursDistant>> getCoursDisponibles() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.effectiveApiUrl}/api/cours'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: AppConfig.apiTimeout));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final coursList = <CoursDistant>[];
        for (var jsonItem in data) {
          try {
            final cours = CoursDistant.fromJson(jsonItem);
            coursList.add(cours);
          } catch (e) {
            if (kDebugMode) {
              print('Erreur parsing cours: $e');
              print('   JSON: $jsonItem');
            }
          }
        }
        return coursList;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion à l\'API: $e');
    }
  }

  Future<List<ModuleDistant>> getModulesDisponibles() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.effectiveApiUrl}/api/modules'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: AppConfig.apiTimeout));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final modulesList = <ModuleDistant>[];
        for (var jsonItem in data) {
          try {
            modulesList.add(ModuleDistant.fromJson(jsonItem));
          } catch (e) {
            if (kDebugMode) {
              print('Erreur parsing module: $e');
              print('   JSON: $jsonItem');
            }
          }
        }
        return modulesList;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion à l\'API (modules): $e');
    }
  }

  /// Récupère les cours distants appartenant à un module donné
  Future<List<CoursDistant>> getCoursDistantsDuModule(int moduleId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.effectiveApiUrl}/api/cours'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: AppConfig.apiTimeout));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final coursList = <CoursDistant>[];
        for (var jsonItem in data) {
          try {
            final cours = CoursDistant.fromJson(jsonItem);
            if (cours.idModule == moduleId) {
              coursList.add(cours);
            }
          } catch (e) {
            if (kDebugMode) print('Erreur parsing cours: $e');
          }
        }
        return coursList;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion à l\'API (cours du module): $e');
    }
  }

  Future<CoursComplet> getCoursComplet(int coursId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.effectiveApiUrl}/api/cours/$coursId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: AppConfig.apiTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final pagesResponse = await http.get(
          Uri.parse('${AppConfig.effectiveApiUrl}/api/pages'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(Duration(seconds: AppConfig.apiTimeout));

        List<PageDistante> pages = [];
        if (pagesResponse.statusCode == 200) {
          final List<dynamic> pagesData = json.decode(pagesResponse.body);
          pages = pagesData
              .where((p) => p['id_cours'] == coursId)
              .map((json) => PageDistante.fromJson(json))
              .toList();
        }

        return CoursComplet.fromJson(data, pages);
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion à l\'API: $e');
    }
  }

  /// Récupère les questions QCM associées à un cours depuis l'API
  Future<List<QcmDistant>> getQcmDuCours(int coursId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.effectiveApiUrl}/api/qcm/$coursId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: AppConfig.apiTimeout));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final list = <QcmDistant>[];
        for (var jsonItem in data) {
          try {
            list.add(QcmDistant.fromJson(jsonItem));
          } catch (e) {
            if (kDebugMode) {
              print('Erreur parsing QCM: $e');
              print('   JSON: $jsonItem');
            }
          }
        }
        return list;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion à l\'API (QCM): $e');
    }
  }

  /// Récupère les questions Cloze (texte à trou) associées à un cours depuis l'API
  Future<List<ClozeDistant>> getClozesDuCours(int coursId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.effectiveApiUrl}/api/text-a-true/$coursId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: AppConfig.apiTimeout));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final list = <ClozeDistant>[];
        for (var jsonItem in data) {
          try {
            list.add(ClozeDistant.fromJson(jsonItem));
          } catch (e) {
            if (kDebugMode) {
              print('Erreur parsing Cloze: $e');
              print('   JSON: $jsonItem');
            }
          }
        }
        return list;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion à l\'API (Cloze): $e');
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.effectiveApiUrl}/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class CoursDistant {
  final int id;
  final String titre;
  final String description;
  final String contenu;
  final int idModule;

  CoursDistant({
    required this.id,
    required this.titre,
    required this.description,
    required this.contenu,
    required this.idModule,
  });

  factory CoursDistant.fromJson(Map<String, dynamic> json) {
    return CoursDistant(
      id: json['id'] as int,
      titre: json['titre']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      contenu: json['contenu']?.toString() ?? '',
      idModule: (json['id_module'] as int?) ?? 0,
    );
  }
}

class PageDistante {
  final int id;
  final String description;
  final String contenu;
  final String medias;
  final int estVue;
  final int idCours;

  PageDistante({
    required this.id,
    required this.description,
    required this.contenu,
    required this.medias,
    required this.estVue,
    required this.idCours,
  });

  factory PageDistante.fromJson(Map<String, dynamic> json) {
    return PageDistante(
      id: json['id'] as int,
      description: json['description']?.toString() ?? '',
      contenu: json['content'] as String? ?? '',
      medias: json['medias']?.toString() ?? '',
      estVue: (json['est_vue'] as int?) ?? 0,
      idCours: json['id_cours'] as int,
    );
  }
}

class CoursComplet {
  final CoursDistant cours;
  final List<PageDistante> pages;

  CoursComplet({required this.cours, required this.pages});

  factory CoursComplet.fromJson(
      Map<String, dynamic> json, List<PageDistante> pages) {
    return CoursComplet(
      cours: CoursDistant.fromJson(json),
      pages: pages,
    );
  }
}

class QcmDistant {
  final int id;
  final String question;
  final String rep1;
  final String rep2;
  final String rep3;
  final String rep4;
  final int soluce;
  final int idCours;

  QcmDistant({
    required this.id,
    required this.question,
    required this.rep1,
    required this.rep2,
    required this.rep3,
    required this.rep4,
    required this.soluce,
    required this.idCours,
  });

  factory QcmDistant.fromJson(Map<String, dynamic> json) {
    return QcmDistant(
      id: json['id'] as int,
      question: json['question']?.toString() ?? '',
      rep1: json['rep1']?.toString() ?? '',
      rep2: json['rep2']?.toString() ?? '',
      rep3: json['rep3']?.toString() ?? '',
      rep4: json['rep4']?.toString() ?? '',
      soluce: (json['soluce'] as int?) ?? 1,
      idCours: json['id_cours'] as int,
    );
  }
}

class ClozeDistant {
  final int id;
  final String texte;
  final String reponse1;
  final String reponse2;
  final String reponse3;
  final String reponse4;
  final int numeroReponseCorrecte;
  final String? explication;
  final int idCours;

  ClozeDistant({
    required this.id,
    required this.texte,
    required this.reponse1,
    required this.reponse2,
    required this.reponse3,
    required this.reponse4,
    required this.numeroReponseCorrecte,
    this.explication,
    required this.idCours,
  });

  factory ClozeDistant.fromJson(Map<String, dynamic> json) {
    return ClozeDistant(
      id: json['id'] as int,
      texte: json['texte']?.toString() ?? '',
      reponse1: json['reponse1']?.toString() ?? '',
      reponse2: json['reponse2']?.toString() ?? '',
      reponse3: json['reponse3']?.toString() ?? '',
      reponse4: json['reponse4']?.toString() ?? '',
      numeroReponseCorrecte: (json['numero_reponse_correcte'] as int?) ?? 1,
      explication: json['explication']?.toString(),
      idCours: json['id_cours'] as int,
    );
  }
}

class ModuleDistant {
  final int id;
  final String titre;
  final String description;

  ModuleDistant({
    required this.id,
    required this.titre,
    required this.description,
  });

  factory ModuleDistant.fromJson(Map<String, dynamic> json) {
    return ModuleDistant(
      id: json['id'] as int,
      titre: json['titre']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}
