import '../models/cours.dart';
import '../repositories/cours_repository.dart';
import '../repositories/objectif_cours_repository.dart';

class CoursService {
  final CoursRepository _coursRepository;
  final ObjectifCoursRepository _objectifRepository;

  // Injection via le constructeur
  CoursService(this._coursRepository, this._objectifRepository);

  // Récupérer un cours et lui ajouter ses objectifs
  Future<Cours?> getCoursWithObjectifs(int coursId) async {
    // Récupérer le cours par son ID
    final cours = await _coursRepository.getById(coursId);
    if (cours == null) return null;

    // Récupérer les objectifs associés au cours
    final objectifs = await _objectifRepository.getByCoursId(coursId);

    // Ajouter les objectifs au cours
    cours.objectifs = objectifs;

    return cours;
  }
}
