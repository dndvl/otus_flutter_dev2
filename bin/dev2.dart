import 'package:dev2/calculator.dart' as calculator;
import 'package:dev2/io.dart' as io;

void main(List<String> arguments) {
  if (arguments.length == 1) {
    var expression = arguments[0];
    print('Expression: $expression');

    // Проверяем наличие неизвестных
    var undefinedVars = io.askUndefinedVars(
        calculator.parseUndefinedVars(expression)
    );

    var calc = calculator.Calculator(expression: expression, undefinedVars: undefinedVars);

    print('Result: ${calc.result()}');
  } else {
    print('Invalid arguments');
  }
}