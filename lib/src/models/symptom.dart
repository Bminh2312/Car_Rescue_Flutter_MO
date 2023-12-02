class Symptom{
  late String id;
  late String symptom1;

  Symptom({
    required this .id,
    required this.symptom1
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'] ?? "",
      symptom1: json['symptom1'] ?? "",
    );
  }
}