/// Modèle représentant une Question dans la base de données.
class Question {
  final int id;
  final String? text;
  final String? imageUrl;
  final String? caption;
  String? type;

  Question({required this.id, this.text, this.imageUrl, this.caption, this.type});

  /// Crée une instance de Question à partir d'une map.
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['idQuestion'],
      text: map.containsKey('txt') ? map['txt'] : "",
      imageUrl: map.containsKey('urlImage') ? map['urlImage'] : "",
      caption: map.containsKey('caption') ? map['caption'] : "", 
      type: map.containsKey('txt') ? 'text' : map.containsKey('urlImage') ? 'image' : 'unknown',
    );
  }

  /// Convertit l'objet Question en map pour la base de données.
  Map<String, dynamic> toMap() {
    return {
      'idQuestion': id,
      'txt': text,
      'urlImage': imageUrl,
      'caption': caption,
      'type': type,
    };
  }
}