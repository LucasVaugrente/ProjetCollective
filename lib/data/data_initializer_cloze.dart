import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

import '../repositories/Cloze/clozeRepository.dart';
import '../models/Cloze/cloze_model.dart';

Future<void> initClozeData() async {
  final csv = await rootBundle.loadString('assets/data/cloze_data.csv');

  final rows = const CsvToListConverter(
    fieldDelimiter: ';',
    shouldParseNumbers: false,
  ).convert(csv);

  rows.removeAt(0);

  final repo = ClozeRepository();

  for (final row in rows) {
    await repo.insert(
      ClozeQuestion(
        phrase: row[0],
        idCours: int.parse(row[1].toString()),
      ),
    );
  }
  print('Cloze data inséré');
}
