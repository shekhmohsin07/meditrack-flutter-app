import 'package:flutter/material.dart';
import 'package:meditrack/l10n/app_localizations.dart';

/// Standard "Are you sure?" dialog. Returns true only if the user confirms.
Future<bool> confirmDelete(BuildContext context, {String? message}) async {
  final t = AppLocalizations.of(context)!;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      content: Text(message ?? t.deleteConfirm),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.cancel)),
        TextButton(onPressed: () => Navigator.pop(c, true), child: Text(t.delete)),
      ],
    ),
  );
  return ok == true;
}
