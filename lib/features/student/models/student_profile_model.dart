class StudentProfileModel {
  /*
    هذا الموديل يمثل بيانات الطالب القادمة من:
    api/Student/my-profile
  */

  final int id;
  final String studentNumber;
  final String fullName;
  final String username;
  final String gender;
  final int? classRoomId;
  final String classRoomName;
  final int? sectionId;
  final String sectionName;
  final String phoneNumber;
  final String parentName;
  final String parentPhone;

  StudentProfileModel({
    required this.id,
    required this.studentNumber,
    required this.fullName,
    required this.username,
    required this.gender,
    required this.classRoomId,
    required this.classRoomName,
    required this.sectionId,
    required this.sectionName,
    required this.phoneNumber,
    required this.parentName,
    required this.parentPhone,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      id: json['id'] ?? json['studentId'] ?? json['StudentId'] ?? 0,
      studentNumber: json['studentNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      gender: json['gender'] ?? '',
      classRoomId: json['classRoomId'],
      classRoomName: json['classRoomName'] ?? '',
      sectionId: json['sectionId'],
      sectionName: json['sectionName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      parentName: json['parentName'] ?? '',
      parentPhone: json['parentPhone'] ?? '',
    );
  }
}

// id: json['id'] ?? json['studentId'] ?? json['StudentId'] ?? 0,
