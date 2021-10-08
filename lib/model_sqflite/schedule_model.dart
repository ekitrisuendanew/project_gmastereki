class ScheduleModel {
  final int? id;
  final String idnotification;
  final String title;
  final String description;
  final String datepicker;
  final String hour;
  final String minute;

  ScheduleModel({this.id, required this.idnotification, required this.title, required this.description, required this.datepicker, required this.hour, required this.minute});

  factory ScheduleModel.fromMap(Map<String, dynamic> json) => ScheduleModel(
    id: json['id'],
    idnotification: json['idnotification'],
    title: json['title'],
    description: json['description'],
    datepicker: json['datepicker'],
    hour: json['hour'],
    minute: json['minute'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idnotification': idnotification,
      'title': title,
      'description': description,
      'datepicker': datepicker,
      'hour': hour,
      'minute': minute,
    };
  }
}