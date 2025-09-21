class MediaCours {
  int? id;
  int idPage;
  int ordre;
  String url;
  String type;
  String? caption;

  MediaCours({
    this.id,
    required this.idPage,
    required this.ordre,
    required this.url,
    required this.type,
    this.caption,
  });

  // Conversion en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_page': idPage,
      'ordre': ordre,
      'url': url,
      'type': type,
      'caption': caption,
    };
  }

  // Conversion d'une Map SQLite en objet MediaCours
  factory MediaCours.fromMap(Map<String, dynamic> map) {
    return MediaCours(
      id: map['id'],
      idPage: map['id_page'],
      ordre: map['ordre'],
      url: map['url'],
      type: map['type'],
      caption: map['caption'],
    );
  }
}
