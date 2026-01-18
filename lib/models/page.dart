import 'dart:convert';

import 'package:flutter/foundation.dart';

class Page {
  int? id;
  String? description;
  int idCours;
  int estVue;
  List<MediaItem>? medias;

  Page({
    this.id,
    this.description,
    required this.idCours,
    this.estVue = 0,
    this.medias,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'id_cours': idCours,
      'est_vue': estVue,
      'medias': medias != null ? jsonEncode(medias!.map((m) => m.toJson()).toList()) : null,
    };
  }

  factory Page.fromMap(Map<String, dynamic> map) {
    List<MediaItem>? mediaList;
    if (map['medias'] != null && map['medias'] != '') {
      try {
        final decoded = jsonDecode(map['medias'] as String) as List;
        mediaList = decoded.map((m) => MediaItem.fromJson(m)).toList();
      } catch (e) {
        if (kDebugMode) {
          print("Erreur parsing medias JSON: $e");
        }
        mediaList = null;
      }
    }

    return Page(
      id: map['id'],
      description: map['description'],
      idCours: map['id_cours'],
      estVue: map['est_vue'] ?? 0,
      medias: mediaList,
    );
  }

  factory Page.fromJson(Map<String, dynamic> json) {
    List<MediaItem>? mediaList;
    if (json['medias'] != null) {
      if (json['medias'] is String) {
        // Si c'est une string JSON, on la décode
        try {
          final decoded = jsonDecode(json['medias']) as List;
          mediaList = decoded.map((m) => MediaItem.fromJson(m)).toList();
        } catch (e) {
          if (kDebugMode) {
            print("Erreur parsing medias JSON string: $e");
          }
        }
      } else if (json['medias'] is List) {
        // Si c'est déjà une liste
        mediaList = (json['medias'] as List).map((m) => MediaItem.fromJson(m)).toList();
      }
    }

    return Page(
      id: json['id'],
      description: json['description'],
      idCours: json['id_cours'],
      estVue: json['est_vue'] ?? 0,
      medias: mediaList,
    );
  }
}

class MediaItem {
  int ordre;
  String url;
  String type;
  String? caption;

  MediaItem({
    required this.ordre,
    required this.url,
    required this.type,
    this.caption,
  });

  Map<String, dynamic> toJson() {
    return {
      'ordre': ordre,
      'url': url,
      'type': type,
      if (caption != null) 'caption': caption,
    };
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      ordre: json['ordre'] ?? 0,
      url: json['url'] ?? '',
      type: json['type'] ?? 'text',
      caption: json['caption'],
    );
  }
}