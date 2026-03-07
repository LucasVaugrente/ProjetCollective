import 'package:get_it/get_it.dart';
import 'package:factoscope/repositories/cours_repository.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Enregistrer les repositories en tant que singletons paresseux
  getIt.registerLazySingleton<CoursRepository>(() => CoursRepository());
}