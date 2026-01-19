import '../repositories/Cloze/clozeRepository.dart';
import '../models/Cloze/cloze_model.dart';

class ClozeService {
  final ClozeRepository _repository = ClozeRepository();

  Future<List<ClozeQuestion>> getQuestionsPourCours(int coursId) async {
    return await _repository.getByCoursId(coursId);
  }

  bool verifierReponse(String saisieUtilisateur, String reponseAttendue) {
    return saisieUtilisateur.trim().toLowerCase() == reponseAttendue.trim().toLowerCase();
  }
}

String extraireSolution(String phrase) {
  final regex = RegExp(r'\[(.*?)\]');
  return regex.firstMatch(phrase)?.group(1) ?? '';
}

String masquerSolution(String phrase) {
  return phrase.replaceAll(RegExp(r'\[.*?\]'), '______');
}
