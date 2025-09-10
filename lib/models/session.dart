class Session {
  final int? id;
  final int trainingId;
  final DateTime date;
  final List<int> plannedReps;
  final List<int> actualReps;
  final int durationSeconds;

  Session({
    this.id,
    required this.trainingId,
    required this.date,
    required this.plannedReps,
    required this.actualReps,
    required this.durationSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'training_id': trainingId,
      'date': date.toIso8601String(),
      'planned_reps': plannedReps.join(','),
      'actual_reps': actualReps.join(','),
      'duration_seconds': durationSeconds,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      trainingId: map['training_id'],
      date: DateTime.parse(map['date']),
      plannedReps: map['planned_reps'].toString().split(',').map((e) => int.parse(e)).toList(),
      actualReps: map['actual_reps'].toString().split(',').map((e) => int.parse(e)).toList(),
      durationSeconds: map['duration_seconds'],
    );
  }

  int get totalPlannedReps => plannedReps.fold(0, (sum, reps) => sum + reps);
  int get totalActualReps => actualReps.fold(0, (sum, reps) => sum + reps);
  double get completionRate => totalPlannedReps > 0 ? (totalActualReps / totalPlannedReps) * 100 : 0;
}