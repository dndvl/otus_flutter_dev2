import 'dart:io';

// Получаем у пользователя значения неизвестных
Map<String, num> askUndefinedVars(List<String> undefinedVars) {
  Map<String, double> result = {};
  for (var variable in undefinedVars) {
    print('$variable = ?');
    var val = stdin.readLineSync();
    if (val == null) {
      throw Error();
    }
    result[variable] = double.parse(val);
  }
  return result;
}
