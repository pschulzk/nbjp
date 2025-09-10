class Training {
  final int? id;
  final int maxReps;
  final int setsCount;
  final DateTime updatedAt;

  Training({
    this.id,
    required this.maxReps,
    required this.setsCount,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'max_reps': maxReps,
      'sets_count': setsCount,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Training.fromMap(Map<String, dynamic> map) {
    return Training(
      id: map['id'],
      maxReps: map['max_reps'],
      setsCount: map['sets_count'],
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Training copyWith({
    int? id,
    int? maxReps,
    int? setsCount,
    DateTime? updatedAt,
  }) {
    return Training(
      id: id ?? this.id,
      maxReps: maxReps ?? this.maxReps,
      setsCount: setsCount ?? this.setsCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}