import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Récupérer tous les cours disponibles sur le serveur
  Future<List<CoursDistant>> getCoursDisponibles() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.effectiveApiUrl}/api/cours'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CoursDistant.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des cours: ${response.statusCode}');
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
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Récupérer les pages du cours
        final pagesResponse = await http.get(
          Uri.parse('${AppConfig.effectiveApiUrl}/api/pages'),
          headers: {'Content-Type': 'application/json'},
        );

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
        throw Exception('Erreur lors de la récupération du cours: ${response.statusCode}');
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
      id: json['id'],
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      contenu: json['contenu'] ?? '',
      idModule: json['id_module'],
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
      id: json['id'],
      description: json['description'] ?? '',
      medias: json['medias'] ?? '',
      estVue: json['est_vue'] ?? 0,
      idCours: json['id_cours'],
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