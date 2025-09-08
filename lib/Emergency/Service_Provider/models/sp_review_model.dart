// Model for review
class SpReviewModel {
  final String title;
  final String description;
  final String date;
  final int rating;
  final List<String> images;

  SpReviewModel({
    required this.title,
    required this.description,
    required this.date,
    required this.rating,
    required this.images,
  });
}
