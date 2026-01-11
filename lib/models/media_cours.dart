class MediaCours {
  final int? id;
  final String url;
  final String? localPath;
  final String type;
  final int idPage;
  final String? caption;
  final int ordre;

  MediaCours({
    this.id,
    required this.url,
    this.localPath,
    required this.type,
    required this.idPage,
    this.caption,
    this.ordre = 0,
  });

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

  factory MediaCours.fromJson(Map<String, dynamic> json) {
    return MediaCours(
      url: json['url'],
      type: json['type'],
      idPage: json['id_page'] ?? 0,
      caption: json['caption'],
    );
  }
}
