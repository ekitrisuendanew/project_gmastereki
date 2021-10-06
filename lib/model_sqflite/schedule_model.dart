class ScheduleModel {
  final int? id;
  final String name;

  ScheduleModel({this.id, required this.name});

  factory ScheduleModel.fromMap(Map<String, dynamic> json) => ScheduleModel(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}