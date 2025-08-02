class QuizConfig {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final int totalQuestions;
  final bool isRandom;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuizConfig({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.totalQuestions,
    required this.isRandom,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizConfig.fromJson(Map<String, dynamic> json) {
    return QuizConfig(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalQuestions: json['totalQuestions'] as int,
      isRandom: json['isRandom'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalQuestions': totalQuestions,
      'isRandom': isRandom,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 