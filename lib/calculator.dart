class Calculator {
  String expression;
  List<dynamic>? parsedExpression;
  Map<String, num> undefinedVars;

  Calculator({
    required this.expression,
    required this.undefinedVars,
  }) {
    try {
      parsedExpression = parse(expression: expression);
      print(parsedExpression);
    } catch (e) {
      throw 'ParseError';
    }
  }

  List<dynamic> parse({
    required String expression,
  }) {
    List<dynamic> parsed = [];
    // Подставляем в выражение неизвестные
    String tempNumber = '';
    String subExpression = '';
    bool subExpressionStarted = false;
    for (int i = 0; i < expression.length; i++) {
      var char = expression[i];
      if (subExpressionStarted) {
        // todo не работают многоуровневые вложения 100/(10/(10/10))
        if (char == ')') {
          // конец подвыражения
          parsed.add(parse(expression: subExpression));
          subExpression = '';
          subExpressionStarted = false;
        }
        subExpression += char;
      } else {
        if (char == '(') {
          // начало подвыражения
          subExpressionStarted = true;
        } else if (isNumeric(char)) {
          // складываем числа во временную переменную
          tempNumber += char;
        } else if (char == '.') {
          // дробное число
          tempNumber += char;
        } else if (undefinedVars[char] != null) {
          // если неизвестная переменная
          if (tempNumber.isNotEmpty) {
            // если выражение 10x умножаем на number и очищаем ее
            parsed.add(double.parse(tempNumber) * undefinedVars[char]!);
            tempNumber = '';
          } else {
            // просто кладем значение x
            parsed.add(undefinedVars[char]);
          }
        } else {
          // добавляем временное число в результат
          if (tempNumber.isNotEmpty) {
            parsed.add(double.parse(tempNumber));
            tempNumber = '';
          }
          // операция
          switch (char) {
            case '+':
              parsed.add(Operation.plus);
              break;
            case '-':
              var len = parsed.length;
              if (len == 0 || (len > 0 && parsed[len - 1] is Operation)) {
                // отрицательное число
                tempNumber += '-';
              } else {
                parsed.add(Operation.minus);
              }
              break;
            case '*':
              parsed.add(Operation.multiply);
              break;
            case '/':
              parsed.add(Operation.divide);
              break;
            default:
              throw 'UndefinedOperation $char';
          }
        }
      }
    }
    // добавляем крайнее правое число в результат
    if (tempNumber.isNotEmpty) {
      parsed.add(double.parse(tempNumber));
    }

    return parsed;
  }

  double calc(List<dynamic> parsedExpression) {
    // создаем новый лист с обработанными подвыражениями
    var flatListExpression = [];
    for (var expressionItem in parsedExpression) {
      if (expressionItem is List) {
        flatListExpression.add(calc(expressionItem));
      } else {
        flatListExpression.add(expressionItem);
      }
    }

    // приоритетные операции умножение и деление
    while (flatListExpression.contains(Operation.multiply) ||
        flatListExpression.contains(Operation.divide)) {
      var index = flatListExpression.indexOf(Operation.multiply);
      if (index != -1) {
        flatListExpression[index - 1] =
            flatListExpression[index - 1] * flatListExpression[index + 1];
      } else {
        index = flatListExpression.indexOf(Operation.divide);
        flatListExpression[index - 1] =
            flatListExpression[index - 1] / flatListExpression[index + 1];
      }
      flatListExpression = flatListExpression.splice(index, 2);
    }

    double result = 0;
    Operation? operation;
    for (var expressionItem in flatListExpression) {
      if (expressionItem is Operation) {
        operation = expressionItem;
      } else {
        if (operation != null) {
          switch (operation) {
            case Operation.plus:
              result += expressionItem;
              break;
            case Operation.minus:
              result -= expressionItem;
              break;
            case Operation.multiply:
              result *= expressionItem;
              break;
            case Operation.divide:
              result /= expressionItem;
              break;
          }
          operation = null;
        } else {
          result = expressionItem;
        }
      }
    }

    return result;
  }

  double result() {
    try {
      return calc(parsedExpression ?? []);
    } catch (e) {
      throw 'ResultError';
    }
  }
}

enum Operation {
  plus,
  minus,
  multiply,
  divide,
}

extension ListSplice on List {
  List<dynamic> splice(int start, int len) {
    var list = [];
    if (start > 0) {
      list = [
        ...sublist(0, start),
      ];
    }
    if (start+len < length) {
      list = [
        ...list,
        ...sublist(start+len),
      ];
    }
    return list;
  }
}

// Ищем неизвестные переменные
List<String> parseUndefinedVars(String expression) {
  List<String> undefinedVars = [];
  for (int i = 0; i < expression.length; i++) {
    var char = expression[i];
    if (!isNumeric(char) &&
        !['.', '+', '-', '*', '/', '(', ')'].contains(char)) {
      undefinedVars.add(char);
    }
  }
  return undefinedVars;
}

bool isNumeric(String s) {
  return double.tryParse(s) != null;
}
