class Notify {
  final String id;
  final String content;
  final String title;
  final DateTime createdAt;
  Notify({
    required this.createdAt,
    required this.id,
    required this.content,
    required this.title,
  });

  factory Notify.fromJson(Map<String, dynamic> json) {
    return Notify(
      id: json['id'] ?? '',
      title: json['tilte'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
