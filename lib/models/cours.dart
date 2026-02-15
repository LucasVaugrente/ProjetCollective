import 'package:factoscope/models/page.dart';

class Cours {
  int? id;
  int? idModule;
  String titre;
  String contenu;
  String description;
  int isDownloaded;
  List<Page>? pages;

  Cours({
    this.id,
    this.idModule,
    required this.titre,
    required this.contenu,
    required this.description,
    this.isDownloaded = 0,
    this.pages,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_module': idModule,
      'titre': titre,
      'contenu': contenu,
      'description': description,
      'is_downloaded': isDownloaded,
    };
  }

  factory Cours.fromMap(Map<String, dynamic> map) {
    return Cours(
      id: map['id'],
      idModule: map['id_module'] as int?,
      titre: map['titre'],
      contenu: map['contenu'],
      description: map['description'],
      isDownloaded: map['is_downloaded'] ?? 0,
    );
  }

  factory Cours.fromJson(Map<String, dynamic> json) {
    return Cours(
      id: json['id'],
      idModule: json['id_module'],
      titre: json['titre'],
      contenu: json['contenu'] ?? json['description'],
      description: json['description'],
      isDownloaded: 1,
      pages: json['pages'] != null
          ? (json['pages'] as List).map((page) => Page.fromJson(page)).toList()
          : null,
    );
  }
}