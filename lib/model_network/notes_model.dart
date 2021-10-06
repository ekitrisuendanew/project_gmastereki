class NotesModel {
  final String id;
  final String image;
  final String title;
  final String description;
  final String link;
  final String createdAt;

  NotesModel({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.link,
    required this.createdAt,
  });

  factory NotesModel.fromJson(Map<dynamic, dynamic> json) {
    return NotesModel(
      id: json['id'],
      image: json['image'],
      title: json['title'],
      description: json['description'],
      link: json['link'],
      createdAt: json['created_at'],
    );
  }
}