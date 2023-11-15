class CurrentWeek {
  String id;
  int week;
  int year;
  DateTime startDate;
  DateTime endDate;

  CurrentWeek({
    required this.id,
    required this.week,
    required this.year,
    required this.startDate,
    required this.endDate,
  });

  factory CurrentWeek.fromJson(Map<String, dynamic> json) => CurrentWeek(
        id: json["id"],
        week: json["week"],
        year: json["year"],
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "week": week,
        "year": year,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
      };
}
