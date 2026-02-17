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
      ).timeout(const Duration(seconds: AppConfig.apiTimeout));

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

  // Récupérer les détails d'un cours spécifique avec ses pages
  Future<CoursComplet> getCoursComplet(int coursId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.effectiveApiUrl}/api/cours/$coursId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: AppConfig.apiTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Récupérer les pages du cours
        final pagesResponse = await http.get(
          Uri.parse('${AppConfig.effectiveApiUrl}/api/pages'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: AppConfig.apiTimeout));

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

  // Tester la connexion à l'API
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.effectiveApiUrl}/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      final connected = response.statusCode == 200;

      return connected;
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
  final int? idModule;

  CoursDistant({
    required this.id,
    required this.titre,
    required this.description,
    required this.contenu,
    this.idModule,
  });

  factory CoursDistant.fromJson(Map<String, dynamic> json) {
    return CoursDistant(
      id: json['id'] as int,
      titre: json['titre']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      contenu: json['contenu']?.toString() ?? '',
      idModule: json['id_module'] as int?,
    );
  }
}

class PageDistante {
  final int id;
  final String description;
  final String medias;
  final int estVue;
  final int idCours;

  PageDistante({
    required this.id,
    required this.description,
    required this.medias,
    required this.estVue,
    required this.idCours,
  });

  factory PageDistante.fromJson(Map<String, dynamic> json) {
    return PageDistante(
      id: json['id'] as int,
      description: json['description']?.toString() ?? '',
      medias: json['medias']?.toString() ?? '',
      estVue: (json['est_vue'] as int?) ?? 0,
      idCours: json['id_cours'] as int,
    );
  }
}

class CoursComplet {
  final CoursDistant cours;
  final List<PageDistante> pages;

  CoursComplet({
    required this.cours,
    required this.pages,
  });

  factory CoursComplet.fromJson(Map<String, dynamic> json, List<PageDistante> pages) {
    return CoursComplet(
      cours: CoursDistant.fromJson(json),
      pages: pages,
    );
  }
}