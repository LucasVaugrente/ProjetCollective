import 'data/data_initializer_cloze.dart';

Future<void> insertSampleData() async {
  await insertModules();
  await insertCours();
  await insertPages();
  await initClozeData();
}
