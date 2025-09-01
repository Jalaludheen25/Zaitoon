class RegistrationModel {
  final int? id;
  final String studentName;
  final String className;
  final String schoolName;
  final String gender;
  final String districtId;
  final String districtName;
  final String areaId;
  final String areaName;
  final String unitId;
  final String unitName;

  RegistrationModel({
    this.id,
    required this.studentName,
    required this.className,
    required this.schoolName,
    required this.gender,
    required this.districtId,
    required this.districtName,
    required this.areaId,
    required this.areaName,
    required this.unitId,
    required this.unitName,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_name': studentName,
      'class': className,
      'school_name': schoolName,
      'gender': gender,
      'district_id': districtId,
      'district_name': districtName,
      'area_id': areaId,
      'area_name': areaName,
      'unit_id': unitId,
      'unit_name': unitName,
    };
  }

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['id'],
      studentName: json['student_name'] ?? '',
      className: json['class'] ?? '',
      schoolName: json['school_name'] ?? '',
      gender: json['gender'] ?? '',
      districtId: json['district_id'] ?? '',
      districtName: json['district_name'] ?? '',
      areaId: json['area_id'] ?? '',
      areaName: json['area_name'] ?? '',
      unitId: json['unit_id'] ?? '',
      unitName: json['unit_name'] ?? '',
    );
  }
}

class District {
  final String id;
  final String name;

  District({
    required this.id,
    required this.name,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['_id'] ?? '',
      name: json['title'] ?? '',
    );
  }
}

class Area {
  final String id;
  final String name;
  final String districtId;

  Area({
    required this.id,
    required this.name,
    required this.districtId,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['_id'] ?? '',
      name: json['title'] ?? '',
      districtId: json['district_id'] ?? json['districtId'] ?? '',
    );
  }
}

class Unit {
  final String id;
  final String name;
  final String areaId;

  Unit({
    required this.id,
    required this.name,
    required this.areaId,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['_id'] ?? '',
      name: json['title'] ?? '',
      areaId: json['area_id'] ?? json['areaId'] ?? '',
    );
  }
}
