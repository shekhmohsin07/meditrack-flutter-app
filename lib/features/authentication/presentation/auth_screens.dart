import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/services/firebase_status.dart';
import 'package:meditrack/core/theme/app_dimensions.dart';
import 'package:meditrack/core/utils/validators.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'auth_providers.dart';

/// Turns a validator key into translated text.
String? tr(AppLocalizations t, String? key) => switch (key) {
      null => null,
      'requiredField' => t.requiredField,
      'invalidEmail' => t.invalidEmail,
      'passwordTooShort' => t.passwordTooShort,
      'passwordsDontMatch' => t.passwordsDontMatch,
      'endBeforeStart' => t.endBeforeStart,
      'invalidNumber' => t.invalidNumber,
      _ => key,
    };

/// Shown when the user taps Log in / Register / Send reset link but Firebase is not set up.
/// (Before, those buttons were silently disabled.)
Future<void> showFirebaseSetupDialog(BuildContext context, WidgetRef ref) async {
  final t = AppLocalizations.of(context)!;
  final offline = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(t.firebaseNotConfiguredTitle),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.firebaseNotConfiguredBody),
          if (FirebaseStatus.initError != null) ...[
            const SizedBox(height: 12),
            Text(t.technicalDetails, style: Theme.of(c).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(FirebaseStatus.initError!, maxLines: 6, overflow: TextOverflow.ellipsis, style: Theme.of(c).textTheme.bodySmall),
          ],
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.cancel)),
        TextButton(onPressed: () => Navigator.pop(c, true), child: Text(t.continueOffline)),
      ],
    ),
  );
  if (offline == true) {
    ref.read(sessionProvider.notifier).useOffline();
    if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: SingleChildScrollView( // scrollable so the keyboard never hides fields
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              ...children,
            ]),
          ),
        ),
      );
}

mixin _Busy<T extends StatefulWidget> on State<T> {
  bool busy = false;
  Future<void> run(Future<void> Function() job) async {
    setState(() => busy = true);
    try {
      await job();
    } on FirebaseAuthException catch (e) {
      _msg(e.message ?? e.code);
    } catch (e) {
      _msg(e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _msg(String m) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginState();
}

class _LoginState extends ConsumerState<LoginScreen> with _Busy {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pw = TextEditingController();

  @override
  void dispose() { _email.dispose(); _pw.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final svc = ref.read(authServiceProvider);
    return _AuthScaffold(title: t.login, children: [
      Form(
        key: _form,
        child: Column(children: [
          TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: t.email),
              validator: (v) => tr(t, Validators.email(v))),
          const SizedBox(height: 16),
          TextFormField(controller: _pw, obscureText: true,
              decoration: InputDecoration(labelText: t.password),
              validator: (v) => tr(t, Validators.password(v))),
        ]),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
            child: Text(t.forgotPassword)),
      ),
      FilledButton(
        onPressed: busy ? null : () {
          if (!_form.currentState!.validate()) return;
          if (!svc.available) {
            showFirebaseSetupDialog(context, ref);
            return;
          }
          run(() async { await svc.login(_email.text, _pw.text); });
        },
        child: busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(t.login),
      ),
      TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
          child: Text(t.noAccount)),
      OutlinedButton(
          onPressed: () => ref.read(sessionProvider.notifier).useOffline(),
          child: Text(t.continueOffline)),
    ]);
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<RegisterScreen> with _Busy {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();

  @override
  void dispose() { _name.dispose(); _email.dispose(); _pw.dispose(); _pw2.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final svc = ref.read(authServiceProvider);
    return _AuthScaffold(title: t.createAccount, children: [
      Form(
        key: _form,
        child: Column(children: [
          TextFormField(controller: _name, decoration: InputDecoration(labelText: t.fullName),
              validator: (v) => tr(t, Validators.required(v))),
          const SizedBox(height: 16),
          TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: t.email), validator: (v) => tr(t, Validators.email(v))),
          const SizedBox(height: 16),
          TextFormField(controller: _pw, obscureText: true,
              decoration: InputDecoration(labelText: t.password), validator: (v) => tr(t, Validators.password(v))),
          const SizedBox(height: 16),
          TextFormField(controller: _pw2, obscureText: true,
              decoration: InputDecoration(labelText: t.confirmPassword),
              validator: (v) => v != _pw.text ? t.passwordsDontMatch : null),
        ]),
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: busy ? null : () {
          if (!_form.currentState!.validate()) return;
          if (!svc.available) {
            showFirebaseSetupDialog(context, ref);
            return;
          }
          run(() async {
            await svc.register(_name.text, _email.text, _pw.text);

            if (!context.mounted) return;

            Navigator.of(context).popUntil((r) => r.isFirst);
          });
        },
        child: Text(t.register),
      ),
      TextButton(onPressed: () => Navigator.pop(context), child: Text(t.haveAccount)),
    ]);
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotState();
}

class _ForgotState extends ConsumerState<ForgotPasswordScreen> with _Busy {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() { _email.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final svc = ref.read(authServiceProvider);
    return _AuthScaffold(title: t.forgotPassword, children: [
      Form(
        key: _form,
        child: TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: t.email), validator: (v) => tr(t, Validators.email(v))),
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: busy ? null : () {
          if (!_form.currentState!.validate()) return;
          if (!svc.available) {
            showFirebaseSetupDialog(context, ref);
            return;
          }
          run(() async {
            await svc.sendReset(_email.text);
            _msg(t.resetLinkSent);
          });
        },
        child: Text(t.sendResetLink),
      ),
    ]);
  }
}
