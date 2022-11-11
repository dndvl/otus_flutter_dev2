import 'package:dev2/calculator.dart' as calculator;
import 'package:test/test.dart';

void main() {
  test('calculate', () {
    expect(
      calculator.Calculator(
        expression: '10*5+4/2-1',
        undefinedVars: {},
      ).result(),
      51,
    );

    expect(
      calculator.Calculator(
        expression: '(x*3-5)/5',
        undefinedVars: {'x': 10},
      ).result(),
      5,
    );

    expect(
      calculator.Calculator(
        expression: '3*x+15/(3+2)',
        undefinedVars: {'x': 10},
      ).result(),
      33,
    );
  });
}
