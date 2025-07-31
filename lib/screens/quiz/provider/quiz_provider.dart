import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:zaitoon/screens/quiz/database/quiz_database.dart';
import 'package:zaitoon/screens/quiz/models/quiz_models.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';

class QuizProvider extends ChangeNotifier {
  final QuizDatabase _database = QuizDatabase.instance;
  final HomeProvider homeProvider;
  
  // Quiz state
  List<QuizQuestion> _allQuestions = [];
  List<QuizQuestion> _currentQuizQuestions = [];
  int _currentQuestionIndex = 0;
  Map<int, int> _selectedAnswers = {};
  String _currentLanguage = 'en';
  
  // Session management
  String? _currentSessionUuid;
  DateTime? _sessionStartTime;
  DateTime? _questionStartTime;
  
  // Timer
  Timer? _quizTimer;
  int _totalTimeElapsed = 0; // in seconds
  int _questionTimeElapsed = 0; // in seconds
  
  // Loading states
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  
  // Quiz results
  QuizResult? _currentQuizResult;
  List<QuizSession> _quizHistory = [];
  Map<String, dynamic> _quizStatistics = {};

  QuizProvider(this.homeProvider) {
    _currentLanguage = homeProvider.selectedLanguage;
    _loadQuestions();
    _loadQuizHistory();
    _loadQuizStatistics();
  }

  // Getters
  List<QuizQuestion> get allQuestions => _allQuestions;
  List<QuizQuestion> get currentQuizQuestions => _currentQuizQuestions;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuizQuestion? get currentQuestion => 
      _currentQuizQuestions.isNotEmpty && _currentQuestionIndex < _currentQuizQuestions.length
          ? _currentQuizQuestions[_currentQuestionIndex]
          : null;
  Map<int, int> get selectedAnswers => _selectedAnswers;
  String get currentLanguage => _currentLanguage;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  QuizResult? get currentQuizResult => _currentQuizResult;
  List<QuizSession> get quizHistory => _quizHistory;
  Map<String, dynamic> get quizStatistics => _quizStatistics;
  
  // Timer getters
  int get totalTimeElapsed => _totalTimeElapsed;
  int get questionTimeElapsed => _questionTimeElapsed;
  String get formattedTotalTime => _formatTime(_totalTimeElapsed);
  String get formattedQuestionTime => _formatTime(_questionTimeElapsed);
  
  bool get isQuizActive => _currentSessionUuid != null;
  bool get hasAnsweredCurrentQuestion => 
      currentQuestion != null && _selectedAnswers.containsKey(currentQuestion!.id);
  bool get isLastQuestion => _currentQuestionIndex == _currentQuizQuestions.length - 1;
  int get questionsAnswered => _selectedAnswers.length;
  double get progressPercentage => 
      _currentQuizQuestions.isEmpty ? 0.0 : questionsAnswered / _currentQuizQuestions.length;

  // Load questions from JSON
  Future<void> _loadQuestions() async {
    try {
      _setLoading(true);
      _clearError();
      
      final String jsonString = await rootBundle.loadString('assets/json/quiz_questions.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _allQuestions = (jsonData['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList();
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load questions: $e');
      _setLoading(false);
    }
  }

  // Start a new quiz
  Future<void> startNewQuiz() async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_allQuestions.isEmpty) {
        await _loadQuestions();
      }
      
      // Generate 20 random questions
      final random = Random();
      final shuffledQuestions = List<QuizQuestion>.from(_allQuestions);
      shuffledQuestions.shuffle(random);
      _currentQuizQuestions = shuffledQuestions.take(20).toList();
      
      // Initialize session
      _currentSessionUuid = const Uuid().v4();
      _sessionStartTime = DateTime.now();
      _currentQuestionIndex = 0;
      _selectedAnswers.clear();
      _totalTimeElapsed = 0;
      _questionTimeElapsed = 0;
      
      // Create quiz session in database
      final session = QuizSession(
        sessionUuid: _currentSessionUuid!,
        startTime: _sessionStartTime!,
        language: _currentLanguage,
        totalQuestions: _currentQuizQuestions.length,
      );
      
      await _database.insertQuizSession(session);
      
      // Start timer
      _startTimer();
      _startQuestionTimer();
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to start quiz: $e');
      _setLoading(false);
    }
  }

  // Answer current question
  Future<void> answerQuestion(int selectedOption) async {
    if (currentQuestion == null || _currentSessionUuid == null) return;
    
    try {
      _selectedAnswers[currentQuestion!.id] = selectedOption;
      
      final isCorrect = selectedOption == currentQuestion!.correctAnswer;
      final timeTaken = _questionTimeElapsed;
      
      // Create quiz answer
      final answer = QuizAnswer(
        sessionUuid: _currentSessionUuid!,
        questionId: currentQuestion!.id,
        question: _currentLanguage == 'en' 
            ? currentQuestion!.questionEn 
            : currentQuestion!.questionMl,
        options: _currentLanguage == 'en' 
            ? currentQuestion!.optionsEn 
            : currentQuestion!.optionsMl,
        correctAnswer: currentQuestion!.correctAnswer,
        selectedAnswer: selectedOption,
        timeTaken: timeTaken,
        isCorrect: isCorrect,
      );
      
      await _database.insertQuizAnswer(answer);
      notifyListeners();
    } catch (e) {
      _setError('Failed to save answer: $e');
    }
  }

  // Move to next question
  void nextQuestion() {
    if (_currentQuestionIndex < _currentQuizQuestions.length - 1) {
      _currentQuestionIndex++;
      _resetQuestionTimer();
      notifyListeners();
    }
  }

  // Move to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      _resetQuestionTimer();
      notifyListeners();
    }
  }

  // Go to specific question
  void goToQuestion(int index) {
    if (index >= 0 && index < _currentQuizQuestions.length) {
      _currentQuestionIndex = index;
      _resetQuestionTimer();
      notifyListeners();
    }
  }

  // Submit quiz
  Future<void> submitQuiz() async {
    if (_currentSessionUuid == null) return;
    
    try {
      _setSubmitting(true);
      _clearError();
      
      _stopTimer();
      
      // Calculate results
      final correctAnswers = _selectedAnswers.entries
          .where((entry) {
            final question = _currentQuizQuestions.firstWhere((q) => q.id == entry.key);
            return entry.value == question.correctAnswer;
          })
          .length;
      
      final percentage = (correctAnswers / _currentQuizQuestions.length) * 100;
      final grade = _calculateGrade(percentage);
      
      // Update session in database
      final session = await _database.getQuizSession(_currentSessionUuid!);
      if (session != null) {
        final updatedSession = QuizSession(
          sessionId: session.sessionId,
          sessionUuid: session.sessionUuid,
          startTime: session.startTime,
          endTime: DateTime.now(),
          language: session.language,
          totalQuestions: session.totalQuestions,
          correctAnswers: correctAnswers,
          totalTimeTaken: _totalTimeElapsed,
          isCompleted: true,
          isSubmitted: false,
        );
        
        await _database.updateQuizSession(updatedSession);
        
        // Create quiz result
        final answers = await _database.getQuizAnswers(_currentSessionUuid!);
        _currentQuizResult = QuizResult(
          session: updatedSession,
          answers: answers,
          percentage: percentage,
          grade: grade,
        );
      }
      
      // Reset current quiz state
      _resetQuizState();
      
      // Reload data
      await _loadQuizHistory();
      await _loadQuizStatistics();
      
      _setSubmitting(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to submit quiz: $e');
      _setSubmitting(false);
    }
  }

  // Submit to API (placeholder for actual API call)
  Future<void> submitToAPI(String sessionUuid) async {
    try {
      _setSubmitting(true);
      
      final session = await _database.getQuizSession(sessionUuid);
      final answers = await _database.getQuizAnswers(sessionUuid);
      
      if (session != null) {
        // TODO: Replace with actual API call
        final apiData = {
          'session': session.toMap(),
          'answers': answers.map((a) => a.toMap()).toList(),
        };
        
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        
        // Mark as submitted in database
        await _database.markSessionAsSubmitted(sessionUuid);
        await _loadQuizHistory();
      }
      
      _setSubmitting(false);
    } catch (e) {
      _setError('Failed to submit to API: $e');
      _setSubmitting(false);
    }
  }

  // Load quiz history
  Future<void> _loadQuizHistory() async {
    try {
      _quizHistory = await _database.getCompletedQuizSessions();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load quiz history: $e');
    }
  }

  // Load quiz statistics
  Future<void> _loadQuizStatistics() async {
    try {
      _quizStatistics = await _database.getQuizStatistics();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load quiz statistics: $e');
    }
  }

  // Timer functions
  void _startTimer() {
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _totalTimeElapsed++;
      _questionTimeElapsed++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _quizTimer?.cancel();
    _quizTimer = null;
  }

  void _startQuestionTimer() {
    _questionStartTime = DateTime.now();
    _questionTimeElapsed = 0;
  }

  void _resetQuestionTimer() {
    _questionTimeElapsed = 0;
  }

  // Helper functions
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _calculateGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    if (percentage >= 40) return 'D';
    return 'F';
  }

  void _resetQuizState() {
    _currentQuizQuestions.clear();
    _currentQuestionIndex = 0;
    _selectedAnswers.clear();
    _currentSessionUuid = null;
    _sessionStartTime = null;
    _questionStartTime = null;
    _totalTimeElapsed = 0;
    _questionTimeElapsed = 0;
    _stopTimer();
  }

  // State management helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Language change
  void changeLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
