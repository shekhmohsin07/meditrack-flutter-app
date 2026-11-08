/// Pure validation functions (easy to unit-test). Return an error KEY or null.
class Validators {
  Validators._();
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(String? v) => (v == null || v.trim().isEmpty) ? 'requiredField' : null;
  static String? email(String? v) {
    if (required(v) != null) return 'requiredField';
    return _email.hasMatch(v!.trim()) ? null : 'invalidEmail';
  }
  static String? password(String? v) {
    if (required(v) != null) return 'requiredField';
    return v!.length < 6 ? 'passwordTooShort' : null;
  }
  /// Number >= 0 (commas allowed as decimal separator). Use [positive] for > 0.
  static String? number(String? v, {bool positive = false}) {
    if (required(v) != null) return 'requiredField';
    final n = double.tryParse(v!.trim().replaceAll(',', '.'));
    if (n == null || n < 0 || (positive && n == 0)) return 'invalidNumber';
    return null;
  }

  static String? dateRange(DateTime start, DateTime? end) =>
      (end != null && end.isBefore(start)) ? 'endBeforeStart' : null;
}
