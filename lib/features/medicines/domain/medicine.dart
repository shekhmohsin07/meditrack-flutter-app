enum MedicineType { tablet, capsule, syrup, injection, drops, cream, other }

enum FoodInstruction {
  beforeFood('before_food'),
  afterFood('after_food'),
  withFood('with_food'),
  emptyStomach('empty_stomach'),
  asInstructed('as_instructed');

  const FoodInstruction(this.dbValue);
  final String dbValue;
  static FoodInstruction fromDb(String v) =>
      FoodInstruction.values.firstWhere((e) => e.dbValue == v, orElse: () => asInstructed);
}

class Medicine {
  const Medicine({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.type,
    required this.food,
    required this.startDate,
    this.endDate,
    this.imagePath,
    this.completed = false,
    this.notes,
    this.memberId,
  });

  final String id;
  final String userId;
  final String? memberId;
  final String name;
  final String dosage; // exactly as entered from the prescription
  final MedicineType type;
  final FoodInstruction food;
  final DateTime startDate;
  final DateTime? endDate;
  final String? imagePath;
  final bool completed;
  final String? notes;

  factory Medicine.fromMap(Map<String, Object?> m) => Medicine(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        memberId: m['member_id'] as String?,
        name: m['name'] as String,
        dosage: m['dosage'] as String,
        type: MedicineType.values.firstWhere((e) => e.name == m['type'], orElse: () => MedicineType.other),
        food: FoodInstruction.fromDb(m['food_instruction'] as String),
        startDate: DateTime.parse(m['start_date'] as String),
        endDate: m['end_date'] == null ? null : DateTime.parse(m['end_date'] as String),
        imagePath: m['image_path'] as String?,
        completed: m['status'] == 'completed',
        notes: m['notes'] as String?,
      );

  Map<String, Object?> toMap() => {
        'user_id': userId,
        'member_id': memberId,
        'name': name.trim(),
        'dosage': dosage.trim(),
        'type': type.name,
        'food_instruction': food.dbValue,
        'start_date': startDate.toIso8601String().substring(0, 10),
        'end_date': endDate?.toIso8601String().substring(0, 10),
        'image_path': imagePath,
        'status': completed ? 'completed' : 'active',
        'notes': notes,
      };
}
