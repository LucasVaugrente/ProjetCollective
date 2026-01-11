import 'package:factoscope/models/cours.dart';

class Module {
   int? id;
   String titre;
   String urlImg;
   String description;
   List<Cours>? cours;
  Module({
    this.id,
    required this.urlImg,
    required this.titre,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'urlImg':urlImg,
      'titre': titre,
      'description': description,
    };
  }

  static Module fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'],
      urlImg: map['urlImg'],
      titre: map['titre'],
      description: map['description'],
    );
  }

}
