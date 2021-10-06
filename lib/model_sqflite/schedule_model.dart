class ScheduleModel {
  final int? id;
  final String title;
  final String description;
  final String hour;
  final String minute;

  ScheduleModel({this.id, required this.title, required this.description, required this.hour, required this.minute});

  factory ScheduleModel.fromMap(Map<String, dynamic> json) => ScheduleModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    hour: json['hour'],
    minute: json['minute'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'hour': hour,
      'minute': minute,
    };
  }
}