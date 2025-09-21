/// Modèle représentant une réponse à une question.
class Reponse {
  final int id;
  final int idQCM;
  final String? text;
  final String? imageUrl;
  final String? caption;
  final String type;

  Reponse({required this.id, required this.idQCM, this.text, this.imageUrl, this.caption, required this.type});

  /// Crée une instance de Reponse à partir d'une map.
  factory Reponse.fromMap(Map<String, dynamic> map) {
    return Reponse(
      id: map['idReponse'],
      idQCM: map['idQCM'],
      text: map['txt'],
      imageUrl: map['urlImage'],
      caption: map['caption'],
      type: map.containsKey('txt') ? 'text' : map.containsKey('urlImage') ? 'image' : 'unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idReponse': id,
      'idQCM': idQCM,
      'txt': text,
      'urlImage': imageUrl,
      'caption': caption,
      'type': type,
    };
  }
}
