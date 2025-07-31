class QuizQuestion {
  final int id;
  final String type;
  final String questionEn;
  final String questionMl;
  final List<String> optionsEn;
  final List<String> optionsMl;
  final int correctAnswer;
  final String difficulty;

  QuizQuestion({
    required this.id,
    required this.type,
    required this.questionEn,
    required this.questionMl,
    required this.optionsEn,
    required this.optionsMl,
    required this.correctAnswer,
    required this.difficulty,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      type: json['type'],
      questionEn: json['question_en'],
      questionMl: json['question_ml'],
      optionsEn: List<String>.from(json['options_en']),
      optionsMl: List<String>.from(json['options_ml']),
      correctAnswer: json['correct_answer'],
      difficulty: json['difficulty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'question_en': questionEn,
      'question_ml': questionMl,
      'options_en': optionsEn.join('|'),
      'options_ml': optionsMl.join('|'),
      'correct_answer': correctAnswer,
      'difficulty': difficulty,
    };
  }
}

class QuizSession {
  final int? sessionId;
  final String sessionUuid;
  final DateTime startTime;
  final DateTime? endTime;
  final String language;
  final int totalQuestions;
  final int? correctAnswers;
  final int? totalTimeTaken; // in seconds
  final bool isCompleted;
  final bool isSubmitted;

  QuizSession({
    this.sessionId,
    required this.sessionUuid,
    required this.startTime,
    this.endTime,
    required this.language,
    required this.totalQuestions,
    this.correctAnswers,
    this.totalTimeTaken,
    this.isCompleted = false,
    this.isSubmitted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'session_uuid': sessionUuid,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'language': language,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'total_time_taken': totalTimeTaken,
      'is_completed': isCompleted ? 1 : 0,
      'is_submitted': isSubmitted ? 1 : 0,
    };
  }

  factory QuizSession.fromMap(Map<String, dynamic> map) {
    return QuizSession(
      sessionId: map['session_id'],
      sessionUuid: map['session_uuid'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time']),
      endTime: map['end_time'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['end_time'])
          : null,
      language: map['language'],
      totalQuestions: map['total_questions'],
      correctAnswers: map['correct_answers'],
      totalTimeTaken: map['total_time_taken'],
      isCompleted: map['is_completed'] == 1,
      isSubmitted: map['is_submitted'] == 1,
    );
  }
}

class QuizAnswer {
  final int? answerId;
  final String sessionUuid;
  final int questionId;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final int? selectedAnswer;
  final int timeTaken; // in seconds
  final bool isCorrect;

  QuizAnswer({
    this.answerId,
    required this.sessionUuid,
    required this.questionId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.selectedAnswer,
    required this.timeTaken,
    required this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'answer_id': answerId,
      'session_uuid': sessionUuid,
      'question_id': questionId,
      'question': question,
      'options': options.join('|'),
      'correct_answer': correctAnswer,
      'selected_answer': selectedAnswer,
      'time_taken': timeTaken,
      'is_correct': isCorrect ? 1 : 0,
    };
  }

  factory QuizAnswer.fromMap(Map<String, dynamic> map) {
    return QuizAnswer(
      answerId: map['answer_id'],
      sessionUuid: map['session_uuid'],
      questionId: map['question_id'],
      question: map['question'],
      options: map['options'].split('|'),
      correctAnswer: map['correct_answer'],
      selectedAnswer: map['selected_answer'],
      timeTaken: map['time_taken'],
      isCorrect: map['is_correct'] == 1,
    );
  }
}

class QuizResult {
  final QuizSession session;
  final List<QuizAnswer> answers;
  final double percentage;
  final String grade;

  QuizResult({
    required this.session,
    required this.answers,
    required this.percentage,
    required this.grade,
  });
} 