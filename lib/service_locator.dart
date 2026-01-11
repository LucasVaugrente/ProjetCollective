import 'package:get_it/get_it.dart';
import 'package:factoscope/repositories/cours_repository.dart';
import 'package:factoscope/repositories/objectif_cours_repository.dart';
import 'package:factoscope/services/cours_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Enregistrer les repositories en tant que singletons paresseux
  getIt.registerLazySingleton<CoursRepository>(() => CoursRepository());
  getIt.registerLazySingleton<ObjectifCoursRepository>(
      () => ObjectifCoursRepository());

  // Enregistrer le CoursService en injectant les dépendances
  getIt.registerLazySingleton<CoursService>(
    () => CoursService(
        getIt<CoursRepository>(), getIt<ObjectifCoursRepository>()),
  );
}
