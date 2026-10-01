class StudentNoteModel {
  /*
    هذا الموديل يمثل ملاحظة واحدة للطالب.

    API المستخدم:
    api/Student/my-notes

    في الويب كان API يرجع:
    {
      notes: [...]
    }
  */

  final int id;
  final String noteText;
  final DateTime createdAt;

  StudentNoteModel({
    required this.id,
    required this.noteText,
    required this.createdAt,
  });

  factory StudentNoteModel.fromJson(Map<String, dynamic> json) {
    return StudentNoteModel(
      id: json['id'] ?? 0,
      noteText: json['noteText'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
