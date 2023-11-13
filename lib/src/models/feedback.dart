class FeedbackData {
  final double? rating;
  final int? count;

  FeedbackData({this.rating, this.count});

  // Factory method to create an instance from a map
  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    return FeedbackData(
      rating: json['rating'],
      count: json['count'],
    );
  }
}
