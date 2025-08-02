class Student {
  int? id;
  String name;
  String mobile;
  String gender;
  String className;
  String district;

  Student({
    this.id,
    required this.name,
    required this.mobile,
    required this.gender,
    required this.className,
    required this.district,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'gender': gender,
      'className': className,
      'district': district,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      mobile: map['mobile'],
      gender: map['gender'],
      className: map['className'],
      district: map['district'],
    );
  }

  @override
  String toString() {
    return 'Student{id: $id, name: $name, mobile: $mobile, gender: $gender, class: $className, district: $district}';
  }
}
