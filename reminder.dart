class Reminder {
  int id;
  String text;
  DateTime? dateTime;

  Reminder({required this.id, required this.text, this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'dateTime': dateTime?.toIso8601String(),
    };
  }

  static Reminder fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      text: map['text'],
      dateTime:
          map['dateTime'] != null ? DateTime.parse(map['dateTime']) : null,
    );
  }
}
