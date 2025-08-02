class QuizLoginModel {
  final String userId;
  final String token;
  final String mobile;

  QuizLoginModel({
    required this.userId,
    required this.token,
    required this.mobile,
  });

  factory QuizLoginModel.fromJson(Map<String, dynamic> json) {
    return QuizLoginModel(
      userId: json['userId']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'token': token,
      'mobile': mobile,
    };
  }
} 