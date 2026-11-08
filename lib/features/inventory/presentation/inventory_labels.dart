import 'package:flutter/material.dart';
import 'package:meditrack/core/theme/app_colors.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import '../domain/inventory.dart';

extension InventoryLabels on AppLocalizations {
  String stockLabel(StockStatus s) => switch (s) {
        StockStatus.ok => stockOk,
        StockStatus.low => stockLow,
        StockStatus.out => stockOut,
        StockStatus.expiringSoon => expiringSoon,
        StockStatus.expired => expired,
      };

  String reasonLabel(String r) => switch (r) {
        'initial' => reasonInitial,
        'intake' => reasonIntake,
        'refill' => reasonRefill,
        _ => reasonManual,
      };
}

(Color, Color) stockColors(StockStatus s) => switch (s) {
      StockStatus.ok => (AppColors.success, AppColors.lightGreen),
      StockStatus.expiringSoon => (AppColors.warning, AppColors.lightOrange),
      StockStatus.low => (AppColors.warning, AppColors.lightOrange),
      StockStatus.out => (AppColors.danger, AppColors.lightRed),
      StockStatus.expired => (AppColors.danger, AppColors.lightRed),
    };
