class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
    this.birthDate,
    this.caregiverConsent = false,
    this.consentAt,
  });
  final String id; // '' when new
  final String name;
  final String relationship; // key: spouse | parent | child | sibling | grandparent | friend | other
  final DateTime? birthDate;
  final bool caregiverConsent; // the member agreed that the owner may track them and get missed-dose alerts
  final DateTime? consentAt;

  static const relationships = ['spouse', 'parent', 'child', 'sibling', 'grandparent', 'friend', 'other'];

  factory FamilyMember.fromMap(Map<String, Object?> m) => FamilyMember(
        id: m['id'] as String,
        name: m['name'] as String,
        relationship: m['relationship'] as String,
        birthDate: m['birth_date'] == null ? null : DateTime.parse(m['birth_date'] as String),
        caregiverConsent: m['caregiver_consent'] == 1,
        consentAt: m['consent_at'] == null ? null : DateTime.parse(m['consent_at'] as String).toLocal(),
      );

  Map<String, Object?> toMap(String userId) => {
        'user_id': userId,
        'name': name.trim(),
        'relationship': relationship,
        'birth_date': birthDate?.toIso8601String().substring(0, 10),
        'caregiver_consent': caregiverConsent ? 1 : 0,
        'consent_at': caregiverConsent ? (consentAt ?? DateTime.now()).toUtc().toIso8601String() : null,
      };
}
