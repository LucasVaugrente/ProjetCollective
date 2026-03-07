import '../repositories/Cloze/cloze_repository.dart';
import '../models/Cloze/cloze_page.dart';

class ClozeService {
  final ClozeRepository _repository = ClozeRepository();

  Future<List<ClozeQuestion>> getQuestionsPourCours(int coursId) async {
    return await _repository.getByCoursId(coursId);
  }

  bool verifierReponse(String saisieUtilisateur, String reponseAttendue) {
    return saisieUtilisateur.trim().toLowerCase() == reponseAttendue.trim().toLowerCase();
  }
}