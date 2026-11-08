import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/core/utils/validators.dart';

void main() {
  test('email validation', () {
    expect(Validators.email(''), 'requiredField');
    expect(Validators.email('abc'), 'invalidEmail');
    expect(Validators.email('a@b.com'), isNull);
  });
  test('password needs 6+ characters', () {
    expect(Validators.password('123'), 'passwordTooShort');
    expect(Validators.password('123456'), isNull);
  });
  test('end date cannot precede start date', () {
    final s = DateTime(2026, 5, 10);
    expect(Validators.dateRange(s, DateTime(2026, 5, 1)), 'endBeforeStart');
    expect(Validators.dateRange(s, null), isNull);
  });
}
