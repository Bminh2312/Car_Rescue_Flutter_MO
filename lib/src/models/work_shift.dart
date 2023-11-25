class WorkShift {
  final String id;
  final String? technicianId;
  final String workScheduleId;
  final DateTime date;
  final String type;

  WorkShift({
    required this.id,
    required this.technicianId,
    required this.workScheduleId,
    required this.date,
    required this.type,
  });

  factory WorkShift.fromJson(Map<String, dynamic> json) {
    return WorkShift(
      id: json['id'],
      technicianId: json['technicianId'] ?? '',
      workScheduleId: json['workScheduleId'],
      date: DateTime.parse(json['date']),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'technicianId': technicianId ?? '',
      'workScheduleId': workScheduleId,
      'date': date.toIso8601String(),
      'type': type,
    };
  }
}
