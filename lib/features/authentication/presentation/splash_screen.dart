import 'package:flutter/material.dart';
import 'package:meditrack/core/theme/app_colors.dart';

/// Shown while the local database opens.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: AppColors.primaryBlue,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.medication_rounded, size: 72, color: AppColors.white),
            SizedBox(height: 16),
            Text('MediTrack', style: TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.w700)),
            SizedBox(height: 24),
            SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white)),
          ]),
        ),
      );
}
