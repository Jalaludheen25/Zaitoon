class QuizLoginModel {
  final String mobile;
  final String userId;
  final DateTime createdAt;
  final bool isVerified;

  QuizLoginModel({
    required this.mobile,
    required this.userId,
    required this.createdAt,
    this.isVerified = false,
  });

  factory QuizLoginModel.fromJson(Map<String, dynamic> json) {
    return QuizLoginModel(
      mobile: json['mobile'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  QuizLoginModel copyWith({
    String? mobile,
    String? userId,
    DateTime? createdAt,
    bool? isVerified,
  }) {
    return QuizLoginModel(
      mobile: mobile ?? this.mobile,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
} 