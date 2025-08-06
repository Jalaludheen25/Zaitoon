import 'package:zaitoon/screens/student_form/model/student_model.dart';

class Student {
  final String name;
  final String mobile;
  final String gender;
  final String className;
  final String district;
  final String language;

  Student({
    required this.name,
    required this.mobile,
    required this.gender,
    required this.className,
    required this.district,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'gender': gender,
      'class': className,
      'district': district,
      'language': language,
    };
  }
}

class QuizSubmissionModel {
  final Student userDetails;
  final List<QuizSubmissionQuestion> questions;
  final List<QuizSubmissionAnswer> answers;
  final QuizSubmissionResult result;
  final int totalQuestions;
  final int totalQuestionsAttended;
  final int timeTaken;

  QuizSubmissionModel({
    required this.userDetails,
    required this.questions,
    required this.answers,
    required this.result,
    required this.totalQuestions,
    required this.totalQuestionsAttended,
    required this.timeTaken,
  });

  Map<String, dynamic> toJson() {
    return {
      'userDetails': userDetails.toJson(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'answers': answers.map((a) => a.toJson()).toList(),
      'result': result.toJson(),
      'totalQuestions': totalQuestions,
      'totalQuestionsAttended': totalQuestionsAttended,
      'timeTaken': timeTaken,
    };
  }
}

class QuizSubmissionQuestion {
  final int questionNumber;
  final String question;
  final List<String> options;
  final String correctAnswer;

  QuizSubmissionQuestion({
    required this.questionNumber,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionNumber': questionNumber,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}

class QuizSubmissionAnswer {
  final int questionNumber;
  final String selectedAnswer;

  QuizSubmissionAnswer({
    required this.questionNumber,
    required this.selectedAnswer,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionNumber': questionNumber,
      'selectedAnswer': selectedAnswer,
    };
  }
}

class QuizSubmissionResult {
  final int score;
  final int correctAnswers;
  final double percentage;

  QuizSubmissionResult({
    required this.score,
    required this.correctAnswers,
    required this.percentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'correctAnswers': correctAnswers,
      'percentage': percentage,
    };
  }
} 