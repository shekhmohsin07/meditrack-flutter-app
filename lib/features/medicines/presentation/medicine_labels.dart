import 'package:meditrack/l10n/app_localizations.dart';
import '../domain/medicine.dart';

extension MedicineLabels on AppLocalizations {
  String typeLabel(MedicineType t) => switch (t) {
        MedicineType.tablet => typeTablet,
        MedicineType.capsule => typeCapsule,
        MedicineType.syrup => typeSyrup,
        MedicineType.injection => typeInjection,
        MedicineType.drops => typeDrops,
        MedicineType.cream => typeCream,
        MedicineType.other => typeOther,
      };

  String foodLabel(FoodInstruction f) => switch (f) {
        FoodInstruction.beforeFood => foodBefore,
        FoodInstruction.afterFood => foodAfter,
        FoodInstruction.withFood => foodWith,
        FoodInstruction.emptyStomach => foodEmpty,
        FoodInstruction.asInstructed => foodDoctor,
      };
}
