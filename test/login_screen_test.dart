import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/authentication/presentation/auth_providers.dart';
import 'package:meditrack/features/authentication/presentation/auth_screens.dart';
import 'helpers/test_app.dart';

void main() {
  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(await buildTestApp(const LoginScreen(), signedIn: false, overrides: dataOverrides()));
    await tester.pumpAndSettle();
  }

  testWidgets('login screen shows its fields and an enabled Log in button', (tester) async {
    await pumpLogin(tester);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    final loginButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Log in'));
    expect(loginButton.onPressed, isNotNull); // regression: it used to be disabled without Firebase
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('empty form shows validation errors', (tester) async {
    await pumpLogin(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsNWidgets(2));
  });

  testWidgets('without Firebase, Log in explains the problem and offers offline mode', (tester) async {
    await pumpLogin(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'a@b.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Cloud account is not set up'), findsOneWidget);

    final container = ProviderScope.containerOf(tester.element(find.byType(LoginScreen)));
    expect(container.read(sessionProvider), isNull);
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Continue offline (no cloud)')));
    await tester.pumpAndSettle();
    expect(container.read(sessionProvider)?.offline, isTrue);
  });

  testWidgets('"Continue offline" starts an offline session', (tester) async {
    await pumpLogin(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(LoginScreen)));
    expect(container.read(sessionProvider), isNull);
    await tester.tap(find.text('Continue offline (no cloud)'));
    await tester.pump();
    expect(container.read(sessionProvider)?.offline, isTrue);
  });

  testWidgets('register and forgot-password screens can be opened', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('No account? Register'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsWidgets);
    expect(find.text('Confirm password'), findsOneWidget);
    final register = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Register'));
    expect(register.onPressed, isNotNull);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('Send reset link'), findsOneWidget);
  });
}
