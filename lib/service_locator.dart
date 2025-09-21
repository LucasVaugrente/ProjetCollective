import 'package:get_it/get_it.dart';
import 'package:seriouse_game/repositories/coursRepository.dart';
import 'package:seriouse_game/repositories/objectifCoursRepository.dart';
import 'package:seriouse_game/services/coursService.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Enregistrer les repositories en tant que singletons paresseux
  getIt.registerLazySingleton<CoursRepository>(() => CoursRepository());
  getIt.registerLazySingleton<ObjectifCoursRepository>(() => ObjectifCoursRepository());

  // Enregistrer le CoursService en injectant les dépendances
  getIt.registerLazySingleton<CoursService>(
        () => CoursService(getIt<CoursRepository>(), getIt<ObjectifCoursRepository>()),
  );
}
