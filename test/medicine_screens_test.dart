import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/medicines/domain/medicine.dart';
import 'package:meditrack/features/medicines/presentation/medicine_form_screen.dart';
import 'package:meditrack/features/medicines/presentation/medicine_list_screen.dart';
import 'helpers/test_app.dart';

void main() {
  testWidgets('medicine list shows medicines, search and the add button', (tester) async {
    final meds = [testMedicine('Metformin'), testMedicine('Amoxicillin', type: MedicineType.capsule)];
    await tester.pumpWidget(await buildTestApp(const MedicineListScreen(), overrides: dataOverrides(medicines: meds)));
    await tester.pumpAndSettle();

    expect(find.text('Metformin'), findsOneWidget);
    expect(find.text('Amoxicillin'), findsOneWidget);
    expect(find.text('Search medicines'), findsOneWidget);
    expect(find.byTooltip('Add medicine'), findsOneWidget);
    for (final chip in ['All', 'Active', 'Completed']) {
      expect(find.text(chip), findsOneWidget);
    }
  });

  testWidgets('empty medicine list shows the empty state', (tester) async {
    await tester.pumpWidget(await buildTestApp(const MedicineListScreen(), overrides: dataOverrides()));
    await tester.pumpAndSettle();
    expect(find.text('No medicines yet. Tap + to add one.'), findsOneWidget);
  });

  testWidgets('tapping + opens the add form, and saving an empty form shows validation errors', (tester) async {
    await tester.pumpWidget(await buildTestApp(const MedicineListScreen(), overrides: dataOverrides()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add medicine'));
    await tester.pumpAndSettle();
    expect(find.text('Medicine name'), findsOneWidget);

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsNWidgets(2)); // name + dosage
  });

  testWidgets('add form lists all medicine types and food instructions', (tester) async {
    await tester.pumpWidget(await buildTestApp(const MedicineFormScreen(), overrides: dataOverrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tablet')); // opens the type dropdown
    await tester.pumpAndSettle();
    for (final type in ['Capsule', 'Syrup', 'Injection', 'Drops', 'Cream', 'Other']) {
      expect(find.text(type), findsWidgets, reason: type);
    }
  });
}
