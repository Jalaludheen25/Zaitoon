import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'package:zaitoon/screens/quiz/database/quiz_database.dart';
import 'package:zaitoon/screens/quiz/models/quiz_models.dart';
import 'package:zaitoon/screens/quiz/models/quiz_submission_model.dart'
    as quiz_submission;
import 'package:zaitoon/screens/quiz/models/quiz_config_model.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/student_form/database/db_helper.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/constants/app_urls.dart';

class QuizProvider extends ChangeNotifier {
  final QuizDatabase _database = QuizDatabase.instance;
  final HomeProvider homeProvider;

  // Notification plugin
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Student details
  String? _studentMobile;

  // Quiz state
  List<QuizQuestion> _allQuestions = [];
  List<QuizQuestion> _currentQuizQuestions = [];
  int _currentQuestionIndex = 0;
  Map<int, int> _selectedAnswers = {};
  String _currentLanguage = 'en';

  // Quiz configuration
  QuizConfig? _quizConfig;
  Timer? _configCheckTimer;

  // Getters
  QuizConfig? get quizConfig => _quizConfig;
  Future<bool> get isQuizTimeValid async {
    if (_quizConfig == null) return false;
    return await canAttemptQuiz();
  }

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
  bool _needsRetry = false;
  String? _submissionError;

  // Add getters
  bool get needsRetry => _needsRetry;
  String? get submissionError => _submissionError;

  // Add new field to store attemptId
  String? _lastAttemptId;
  String? get lastAttemptId => _lastAttemptId;

  QuizProvider(this.homeProvider) {
    _currentLanguage = homeProvider.selectedLanguage;
    _initializeNotifications();
    _loadQuestions();
    _loadQuizHistory();
    _loadQuizStatistics();
    loadQuizConfig();
    _startConfigCheckTimer();
    _loadAttemptId(); // Add this line
    _loadLastStudentMobile(); // Add this line
  }

  // Initialize notifications
  Future<void> _initializeNotifications() async {
    try {
      debugPrint('=== INITIALIZING NOTIFICATIONS ===');

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions for Android 13+
      if (Platform.isAndroid) {
        await Permission.notification.request();
      }

      debugPrint('Notifications initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    debugPrint('Notification tapped: ${notificationResponse.payload}');

    if (notificationResponse.payload != null) {
      final filePath = notificationResponse.payload!;
      _openCertificateFile(filePath);
    }
  }

  // Show download notification
  Future<void> _showDownloadNotification(
      String fileName, String filePath) async {
    try {
      debugPrint('=== SHOWING DOWNLOAD NOTIFICATION ===');

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'download_channel',
        'Downloads',
        channelDescription: 'Notifications for downloaded files',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(''),
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _notificationsPlugin.show(
        0, // notification id
        'Download Complete',
        'Certificate saved: $fileName',
        platformChannelSpecifics,
        payload: filePath,
      );

      debugPrint('Download notification shown successfully');
    } catch (e) {
      debugPrint('Error showing download notification: $e');
    }
  }

  // Add method to load attemptId
  Future<void> _loadAttemptId() async {
    try {
      debugPrint('Loading attemptId from database...');
      final latestSession = await _database.getLatestSubmittedSession();
      if (latestSession != null) {
        _lastAttemptId = latestSession.attemptId;
        debugPrint('Loaded attemptId: $_lastAttemptId');
        debugPrint('Session details:');
        debugPrint('- Session UUID: ${latestSession.sessionUuid}');
        debugPrint('- Is Completed: ${latestSession.isCompleted}');
        debugPrint('- Is Submitted: ${latestSession.isSubmitted}');
        debugPrint('- Attempt ID: ${latestSession.attemptId}');
      } else {
        debugPrint('No submitted session found');
        debugPrint('Checking all completed sessions...');
        final allSessions = await _database.getCompletedQuizSessions();
        debugPrint('Total completed sessions: ${allSessions.length}');
        for (var session in allSessions) {
          debugPrint(
              '- Session: ${session.sessionUuid}, Submitted: ${session.isSubmitted}, AttemptId: ${session.attemptId}');
        }
      }
    } catch (e) {
      debugPrint('Error loading attemptId: $e');
    }
  }

  // Add method to load last student mobile
  Future<void> _loadLastStudentMobile() async {
    try {
      debugPrint('Loading last student mobile from database...');
      final dbHelper = DatabaseHelper();
      final students = await dbHelper.getAllStudents();
      if (students.isNotEmpty) {
        _studentMobile = students.last.mobile;
        debugPrint('Loaded student mobile: $_studentMobile');
      } else {
        debugPrint('No students found in database');
      }
    } catch (e) {
      debugPrint('Error loading student mobile: $e');
    }
  }

  // Getters
  List<QuizQuestion> get allQuestions => _allQuestions;
  List<QuizQuestion> get currentQuizQuestions => _currentQuizQuestions;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuizQuestion? get currentQuestion => _currentQuizQuestions.isNotEmpty &&
          _currentQuestionIndex < _currentQuizQuestions.length
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
      currentQuestion != null &&
      _selectedAnswers.containsKey(currentQuestion!.id);
  bool get isLastQuestion =>
      _currentQuestionIndex == _currentQuizQuestions.length - 1;
  int get questionsAnswered => _selectedAnswers.length;
  double get progressPercentage => _currentQuizQuestions.isEmpty
      ? 0.0
      : questionsAnswered / _currentQuizQuestions.length;

  // Public method to load questions (for external access)
  Future<void> loadQuestions() async {
    await _loadQuestions();
  }

  // Load questions from JSON
  Future<void> _loadQuestions() async {
    try {
      debugPrint('=== LOADING QUESTIONS ===');
      _setLoading(true);
      _clearError();

      debugPrint('Reading questions from JSON file...');
      final String jsonString =
          await rootBundle.loadString('assets/json/quiz_questions.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _allQuestions = (jsonData['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList();

      debugPrint('Loaded ${_allQuestions.length} questions');
      _setLoading(false);
    } catch (e) {
      debugPrint('Error loading questions: $e');
      _setError('Failed to load questions: $e');
      _setLoading(false);
    }
  }

  // Check if quiz can be started or continued
  Future<bool> canAttemptQuiz() async {
    try {
      if (_quizConfig == null) return false;

      final now = DateTime.now();
      debugPrint('Checking quiz attempt validity:');
      debugPrint('Current time: $now');
      debugPrint('Quiz start time: ${_quizConfig!.startDate}');
      debugPrint('Quiz end time: ${_quizConfig!.endDate}');

      if (now.isBefore(_quizConfig!.startDate)) {
        debugPrint('Quiz has not started yet');
        return false;
      }

      if (now.isAfter(_quizConfig!.endDate)) {
        debugPrint('Quiz time is over');
        return false;
      }

      // Check if user has already attempted from local DB
      final hasAttempted = await _hasAttemptedQuiz();
      if (hasAttempted) {
        debugPrint('User has already attempted quiz (local DB check)');
        return false;
      }

      debugPrint('Quiz can be attempted');
      return true;
    } catch (e) {
      debugPrint('Error checking quiz attempt validity: $e');
      return false;
    }
  }

  // Check if user has already attempted quiz from local DB
  Future<bool> _hasAttemptedQuiz() async {
    try {
      debugPrint('Checking quiz attempts in local DB...');
      // Get completed quiz sessions from local DB
      final completedSessions = await _database.getCompletedQuizSessions();
      debugPrint('Found ${completedSessions.length} completed sessions');

      // Check if any session exists that is completed and submitted
      final hasCompletedSession = completedSessions
          .any((session) => session.isCompleted && session.isSubmitted);

      if (hasCompletedSession) {
        debugPrint('Found completed and submitted session');
      } else {
        debugPrint('No completed and submitted session found');
      }

      return hasCompletedSession;
    } catch (e) {
      debugPrint('Error checking quiz attempt in local DB: $e');
      return false;
    }
  }

  // Load quiz configuration from API
  Future<void> loadQuizConfig() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://zaitoon-quiz-fdaeq.ondigitalocean.app/api/admin/dashboard'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _quizConfig = QuizConfig.fromJson(data['data']);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading quiz config: $e');
      throw Exception('Failed to load quiz configuration: $e');
    }
  }

  // Start timer to check quiz time periodically
  void _startConfigCheckTimer() {
    debugPrint('Starting config check timer');
    _configCheckTimer?.cancel();
    _configCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_quizConfig != null) {
        final now = DateTime.now();
        debugPrint('Checking quiz time validity at: $now');
        debugPrint('Quiz end time: ${_quizConfig!.endDate}');

        if (now.isAfter(_quizConfig!.endDate)) {
          debugPrint('Quiz time has ended. Forcing submission.');
          timer.cancel();
          // If there's an active quiz, force submit it
          if (isQuizActive && _currentSessionUuid != null) {
            debugPrint('Active quiz found. Triggering force submission.');
            _forceSubmitQuiz();
          }
          notifyListeners();
        }
      }
    });
  }

  // Force submit quiz when time expires
  Future<void> _forceSubmitQuiz() async {
    try {
      debugPrint('=== FORCE SUBMITTING QUIZ ===');
      _stopTimer();

      // Calculate results
      final correctAnswers = _selectedAnswers.entries.where((entry) {
        final question =
            _currentQuizQuestions.firstWhere((q) => q.id == entry.key);
        return entry.value == question.correctAnswer;
      }).length;

      final percentage = (correctAnswers / _currentQuizQuestions.length) * 100;

      debugPrint('Force submission details:');
      debugPrint('- Session UUID: $_currentSessionUuid');
      debugPrint(
          '- Questions Answered: ${_selectedAnswers.length}/${_currentQuizQuestions.length}');
      debugPrint('- Correct Answers: $correctAnswers');
      debugPrint('- Score: $percentage%');

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
        debugPrint('Session updated in local database');

        // Get quiz answers
        final answers = await _database.getQuizAnswers(_currentSessionUuid!);

        // Try to submit to API
        try {
          await submitToAPI(updatedSession, answers);
          debugPrint('Quiz submitted to API successfully');
        } catch (e) {
          debugPrint('Failed to submit to API: $e');
          // We don't throw here as we want to continue with local updates
        }
      }

      // Reset quiz state
      _resetQuizState();

      // Reload data
      await _loadQuizHistory();
      await _loadQuizStatistics();

      debugPrint('Force submission complete');
      notifyListeners();
    } catch (e) {
      debugPrint('Error during force submission: $e');
      // We don't throw here as this is an automatic process
    }
  }

  // Start a new quiz
  Future<void> startNewQuiz() async {
    try {
      // Check if quiz config is loaded
      if (_quizConfig == null) {
        await loadQuizConfig();
        if (_quizConfig == null) {
          throw Exception(
              'Quiz configuration not available. Please try again later.');
        }
      }

      // Check quiz timing
      final now = DateTime.now();
      if (now.isBefore(_quizConfig!.startDate)) {
        throw Exception(
            'Quiz has not started yet. Start time: ${_formatDateTime(_quizConfig!.startDate)}');
      }
      if (now.isAfter(_quizConfig!.endDate)) {
        throw Exception(
            'Quiz time is over. End time was: ${_formatDateTime(_quizConfig!.endDate)}');
      }

      // Check if user has already attempted from local DB
      final hasAttempted = await _hasAttemptedQuiz();
      if (hasAttempted) {
        throw Exception(
            'You have already attempted this quiz. Only one attempt is allowed.');
      }

      _setLoading(true);
      _clearError();

      if (_allQuestions.isEmpty) {
        await _loadQuestions();
      }

      // Get questions based on config
      final questions = List<QuizQuestion>.from(_allQuestions);
      if (_quizConfig!.isRandom) {
        questions.shuffle(Random());
      }
      _currentQuizQuestions =
          questions.take(_quizConfig!.totalQuestions).toList();

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
      _setLoading(false);
      rethrow;
    }
  }

  // Answer current question
  Future<void> answerQuestion(int selectedOption) async {
    if (currentQuestion == null || _currentSessionUuid == null) return;

    try {
      debugPrint('=== SAVING ANSWER DEBUG ===');
      debugPrint('Session UUID: $_currentSessionUuid');
      debugPrint('Question ID: ${currentQuestion!.id}');
      debugPrint('Selected Option Index: $selectedOption');
      debugPrint(
          'Question Text: ${_currentLanguage == 'en' ? currentQuestion!.questionEn : currentQuestion!.questionMl}');
      debugPrint(
          'Selected Answer Text: ${_currentLanguage == 'en' ? currentQuestion!.optionsEn[selectedOption] : currentQuestion!.optionsMl[selectedOption]}');

      _selectedAnswers[currentQuestion!.id] = selectedOption;

      final isCorrect = selectedOption == currentQuestion!.correctAnswer;
      final timeTaken = _questionTimeElapsed;

      debugPrint('Is Correct Answer: $isCorrect');
      debugPrint('Time Taken: $timeTaken seconds');

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
    debugPrint('=== MOVING TO NEXT QUESTION ===');
    if (_currentQuestionIndex < _currentQuizQuestions.length - 1) {
      _currentQuestionIndex++;
      debugPrint('New question index: $_currentQuestionIndex');
      _resetQuestionTimer();
      notifyListeners();
    } else {
      debugPrint('Already at last question');
    }
  }

  // Move to previous question
  void previousQuestion() {
    debugPrint('=== MOVING TO PREVIOUS QUESTION ===');
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      debugPrint('New question index: $_currentQuestionIndex');
      _resetQuestionTimer();
      notifyListeners();
    } else {
      debugPrint('Already at first question');
    }
  }

  // Go to specific question
  void goToQuestion(int index) {
    debugPrint('=== GOING TO QUESTION $index ===');
    if (index >= 0 && index < _currentQuizQuestions.length) {
      _currentQuestionIndex = index;
      debugPrint('Question navigation successful');
      _resetQuestionTimer();
      notifyListeners();
    } else {
      debugPrint('Invalid question index: $index');
    }
  }

  // Submit quiz
  Future<void> submitQuiz(BuildContext context) async {
    if (_currentSessionUuid == null) return;

    try {
      _setSubmitting(true);
      _clearError();
      _needsRetry = false;
      _submissionError = null;

      _stopTimer();

      // Calculate results
      final correctAnswers = _selectedAnswers.entries.where((entry) {
        final question =
            _currentQuizQuestions.firstWhere((q) => q.id == entry.key);
        return entry.value == question.correctAnswer;
      }).length;

      final percentage = (correctAnswers / _currentQuizQuestions.length) * 100;

      debugPrint('=== QUIZ SUBMISSION DEBUG ===');
      debugPrint('Session UUID: $_currentSessionUuid');
      debugPrint('Total Questions: ${_currentQuizQuestions.length}');
      debugPrint('Questions Answered: ${_selectedAnswers.length}');
      debugPrint('Correct Answers: $correctAnswers');
      debugPrint('Percentage: $percentage%');
      debugPrint('Total Time: $_totalTimeElapsed seconds');

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
        debugPrint('Session updated in local database');

        // Get quiz answers
        final answers = await _database.getQuizAnswers(_currentSessionUuid!);

        try {
          // Submit to API
          await submitToAPI(updatedSession, answers);
          debugPrint('Quiz submitted to API successfully');

          // Reset quiz state on successful submission
          _resetQuizState();
          await _loadQuizHistory();
          await _loadQuizStatistics();
        } catch (e) {
          debugPrint('API submission error: $e');
          if (e.toString().contains('already attempted')) {
            _needsRetry = true;
            _submissionError =
                'Quiz already submitted. Please retry to sync your results.';
          } else {
            _needsRetry = true;
            _submissionError = 'Failed to submit quiz. Please retry.';
          }
          notifyListeners();
          throw e;
        }
      }

      _setSubmitting(false);
      notifyListeners();
    } catch (e) {
      debugPrint('Error submitting quiz: $e');
      _setError('Failed to submit quiz: $e');
      _setSubmitting(false);
      throw e;
    }
  }

  Future<void> submitToAPI(
      QuizSession session, List<QuizAnswer> answers) async {
    try {
      debugPrint('=== API SUBMISSION DEBUG ===');

      // Get student details
      final dbHelper = DatabaseHelper();
      if (_studentMobile == null) {
        // If no mobile number is set, try to get the last registered student
        final students = await dbHelper.getAllStudents();
        if (students.isEmpty) {
          throw Exception('No student details found. Please register first.');
        }
        _studentMobile = students.last.mobile;
      }

      final student = await dbHelper.getStudentByMobile(_studentMobile!);
      if (student == null) {
        throw Exception('No student details found. Please register first.');
      }

      final studentDetails = quiz_submission.Student(
        name: student.name,
        mobile: student.mobile,
        gender: student.gender,
        className: student.className,
        district: student.district,
        language: _currentLanguage == 'en' ? 'English' : 'Malayalam',
      );

      // Prepare questions and answers for API
      final questions = _currentQuizQuestions.asMap().entries.map((entry) {
        final q = entry.value;
        debugPrint('=== QUESTION MAPPING DEBUG ===');
        debugPrint('Question ${entry.key + 1}: ${q.questionEn}');
        final correctAnswerIndex = q.correctAnswer;
        final correctAnswerText = _currentLanguage == 'en'
            ? q.optionsEn[correctAnswerIndex]
            : q.optionsMl[correctAnswerIndex];
        debugPrint('Correct Answer Index: $correctAnswerIndex');
        debugPrint('Correct Answer Text: $correctAnswerText');

        return quiz_submission.QuizSubmissionQuestion(
          questionNumber: entry.key + 1,
          question: _currentLanguage == 'en' ? q.questionEn : q.questionMl,
          options: _currentLanguage == 'en' ? q.optionsEn : q.optionsMl,
          correctAnswer: correctAnswerText,
        );
      }).toList();

      // Map answers in the same order as questions
      final submissionAnswers =
          _currentQuizQuestions.asMap().entries.map((entry) {
        final index = entry.key;
        final q = entry.value;
        final selectedAnswer = _selectedAnswers[q.id];

        debugPrint('=== ANSWER MAPPING DEBUG ===');
        debugPrint(
            'Question ${index + 1}: ${_currentLanguage == 'en' ? q.questionEn : q.questionMl}');
        debugPrint('Selected Answer Index: $selectedAnswer');
        final selectedAnswerText = selectedAnswer != null
            ? (_currentLanguage == 'en'
                ? q.optionsEn[selectedAnswer]
                : q.optionsMl[selectedAnswer])
            : "";
        debugPrint('Selected Answer Text: $selectedAnswerText');

        return quiz_submission.QuizSubmissionAnswer(
          questionNumber: index + 1,
          selectedAnswer: selectedAnswerText,
        );
      }).toList();

      final result = quiz_submission.QuizSubmissionResult(
        score: session.correctAnswers ?? 0,
        correctAnswers: session.correctAnswers ?? 0,
        percentage:
            (session.correctAnswers ?? 0) / session.totalQuestions * 100,
      );

      debugPrint('=== SUBMISSION DETAILS DEBUG ===');
      debugPrint('Total Questions: ${session.totalQuestions}');
      debugPrint('Questions Answered: ${_selectedAnswers.length}');
      debugPrint('Correct Answers: ${session.correctAnswers}');
      debugPrint(
          'Score Percentage: ${(session.correctAnswers ?? 0) / session.totalQuestions * 100}%');
      debugPrint('Time Taken: ${session.totalTimeTaken} seconds');

      final quizSubmission = quiz_submission.QuizSubmissionModel(
        userDetails: studentDetails,
        questions: questions,
        answers: submissionAnswers,
        result: result,
        totalQuestions: session.totalQuestions,
        totalQuestionsAttended: _selectedAnswers.length,
        timeTaken: session.totalTimeTaken ?? 0,
      );

      debugPrint('API Request Body: ${jsonEncode(quizSubmission.toJson())}');

      final response = await http.post(
        Uri.parse(ApiUrls.submitQuiz()),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(quizSubmission.toJson()),
      );

      debugPrint('=== API RESPONSE DETAILS ===');
      debugPrint('API Response Status: ${response.statusCode}');
      final prettyResponse = const JsonEncoder.withIndent('  ')
          .convert(json.decode(response.body));
      debugPrint('API Response Body:');
      prettyResponse.split('\n').forEach((line) => debugPrint(line));
      debugPrint('=== END API RESPONSE DETAILS ===');

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Failed to submit quiz to API';

        // Check for specific error cases that don't need retry
        if (errorMessage.toLowerCase().contains('already attempted')) {
          // Mark as submitted in local DB since it's already on server
          await _database.markSessionAsSubmitted(session.sessionUuid);
          throw Exception(errorMessage);
        }

        throw Exception('RETRYABLE:$errorMessage');
      }

      // Store attemptId from response
      final responseData = json.decode(response.body);
      debugPrint('=== ATTEMPT ID STORAGE DEBUG ===');
      debugPrint('Response success: ${responseData['success']}');
      debugPrint('Response data: ${responseData['data']}');

      if (responseData['success'] == true && responseData['data'] != null) {
        _lastAttemptId = responseData['data']['attemptId'];
        debugPrint('Stored attemptId from submission: $_lastAttemptId');

        // Update session with attemptId
        final updatedSession = QuizSession(
          sessionId: session.sessionId,
          sessionUuid: session.sessionUuid,
          startTime: session.startTime,
          endTime: session.endTime,
          language: session.language,
          totalQuestions: session.totalQuestions,
          correctAnswers: session.correctAnswers,
          totalTimeTaken: session.totalTimeTaken,
          isCompleted: session.isCompleted,
          isSubmitted: true,
          attemptId: _lastAttemptId,
        );
        await _database.updateQuizSession(updatedSession);
        debugPrint('Updated session with attemptId in database');
        debugPrint('Session UUID: ${session.sessionUuid}');
        debugPrint('Attempt ID: $_lastAttemptId');
      } else {
        debugPrint('Failed to get attemptId from response');
        debugPrint('Response data structure: $responseData');
      }
      debugPrint('=== END ATTEMPT ID STORAGE DEBUG ===');

      // Mark as submitted in local DB
      await _database.markSessionAsSubmitted(session.sessionUuid);
      debugPrint('Local DB: Marked session as submitted');
    } catch (e) {
      debugPrint('Error submitting to API: $e');
      throw e; // Rethrow to handle in the UI
    }
  }

  Future<void> retrySubmission(QuizSession session) async {
    try {
      _setSubmitting(true);
      final answers = await getQuizAnswers(session.sessionUuid);
      await submitToAPI(session, answers);
      _setSubmitting(false);
    } catch (e) {
      _setSubmitting(false);
      rethrow;
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

  // Get quiz answers for a session
  Future<List<QuizAnswer>> getQuizAnswers(String sessionUuid) async {
    return _database.getQuizAnswers(sessionUuid);
  }

  // Delete quiz session
  Future<void> deleteQuizSession(String sessionUuid) async {
    try {
      debugPrint('Deleting quiz session: $sessionUuid');
      await _database.deleteQuizSession(sessionUuid);
      await _loadQuizHistory(); // Reload history after deletion
      await _loadQuizStatistics(); // Reload statistics as they might have changed
      notifyListeners();
      debugPrint('Quiz session deleted successfully');
    } catch (e) {
      debugPrint('Error deleting quiz session: $e');
      throw Exception('Failed to delete quiz session: $e');
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
  String _formatDateTime(DateTime dt) {
    // Convert UTC to local time
    final localDt = dt.toLocal();

    // Get hour in 12-hour format
    int hour = localDt.hour % 12;
    hour = hour == 0 ? 12 : hour; // Convert 0 to 12 for 12 AM

    // Get AM/PM
    final period = localDt.hour < 12 ? 'AM' : 'PM';

    final formatted =
        '${localDt.day}/${localDt.month}/${localDt.year} ${hour}:${localDt.minute.toString().padLeft(2, '0')} $period';
    debugPrint('Formatting datetime: $dt -> $formatted (local time: $localDt)');
    return formatted;
  }

  // Format seconds duration
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final formattedTime =
        '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    debugPrint('Formatting duration $seconds seconds -> $formattedTime');
    return formattedTime;
  }

  // Format clock time
  String formatClockTime(DateTime time) {
    // Convert UTC to local time
    final localTime = time.toLocal();

    // Get hour in 12-hour format
    int hour = localTime.hour % 12;
    hour = hour == 0 ? 12 : hour; // Convert 0 to 12 for 12 AM

    // Get AM/PM
    final period = localTime.hour < 12 ? 'AM' : 'PM';

    return '$hour:${localTime.minute.toString().padLeft(2, '0')} $period';
  }

  String calculateGrade(double percentage) {
    debugPrint('Calculating grade for percentage: $percentage');
    String grade;
    if (percentage >= 90) {
      grade = 'A+';
    } else if (percentage >= 80) {
      grade = 'A';
    } else if (percentage >= 70) {
      grade = 'B+';
    } else if (percentage >= 60) {
      grade = 'B';
    } else if (percentage >= 50) {
      grade = 'C';
    } else if (percentage >= 40) {
      grade = 'D';
    } else {
      grade = 'F';
    }
    debugPrint('Grade calculated: $grade');
    return grade;
  }

  // Add method to clear retry state
  void clearRetryState() {
    _needsRetry = false;
    _submissionError = null;
    notifyListeners();
  }

  // Modify reset quiz state to clear retry state
  void _resetQuizState() {
    debugPrint('=== RESETTING QUIZ STATE ===');
    debugPrint('Clearing current quiz questions');
    _currentQuizQuestions.clear();
    debugPrint('Resetting question index');
    _currentQuestionIndex = 0;
    debugPrint('Clearing selected answers');
    _selectedAnswers.clear();
    debugPrint('Clearing session data');
    _currentSessionUuid = null;
    _sessionStartTime = null;
    _questionStartTime = null;
    debugPrint('Resetting timers');
    _totalTimeElapsed = 0;
    _questionTimeElapsed = 0;
    _stopTimer();
    debugPrint('Clearing retry state');
    _needsRetry = false;
    _submissionError = null;
    debugPrint('Clearing attemptId');
    _lastAttemptId = null;
    debugPrint('Quiz state reset complete');
  }

  // State management helpers
  void _setLoading(bool loading) {
    debugPrint('Setting loading state: $loading');
    _isLoading = loading;
    notifyListeners();
  }

  void _setSubmitting(bool submitting) {
    debugPrint('Setting submitting state: $submitting');
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    debugPrint('Setting error: $error');
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    debugPrint('Clearing error state');
    _error = null;
  }

  // Language change
  void changeLanguage(String language) {
    debugPrint('=== CHANGING LANGUAGE ===');
    debugPrint('Old language: $_currentLanguage');
    debugPrint('New language: $language');
    _currentLanguage = language;
    notifyListeners();
  }

  // Generate certificate locally using Flutter Canvas
  Future<Map<String, dynamic>> downloadCertificate() async {
    try {
      debugPrint('=== GENERATING CERTIFICATE LOCALLY ===');
      debugPrint('Checking quiz history...');
      debugPrint('Total quiz history entries: ${_quizHistory.length}');

      if (_quizHistory.isEmpty) {
        throw Exception(
            'No quiz history found. Please complete the quiz first.');
      }

      // Get the latest completed quiz session
      final latestSession = _quizHistory.first;
      if (!latestSession.isCompleted || !latestSession.isSubmitted) {
        throw Exception(
            'Quiz not completed or submitted. Please complete the quiz first.');
      }

      // Get student details
      final dbHelper = DatabaseHelper();
      if (_studentMobile == null) {
        final students = await dbHelper.getAllStudents();
        if (students.isEmpty) {
          throw Exception('No student details found. Please register first.');
        }
        _studentMobile = students.last.mobile;
      }

      final student = await dbHelper.getStudentByMobile(_studentMobile!);
      if (student == null) {
        throw Exception('No student details found. Please register first.');
      }

      debugPrint('=== STUDENT DETAILS ===');
      debugPrint('Student Name: ${student.name}');
      debugPrint('Student Mobile: ${student.mobile}');
      debugPrint('Student Class: ${student.className}');
      debugPrint('Student District: ${student.district}');

      // Calculate quiz score
      final correctAnswers = latestSession.correctAnswers ?? 0;
      final totalQuestions = latestSession.totalQuestions;
      final percentage = (correctAnswers / totalQuestions * 100).round();

      debugPrint('=== QUIZ RESULTS ===');
      debugPrint('Correct Answers: $correctAnswers');
      debugPrint('Total Questions: $totalQuestions');
      debugPrint('Percentage: $percentage%');

      // Generate certificate using Canvas
      final certificateBytes = await _generateCertificateWithCanvas(
        student.name,
      );

      // Save certificate to downloads folder
      final filePath =
          await _saveCertificateToDownloads(certificateBytes, student.name);

      debugPrint('=== CERTIFICATE GENERATED SUCCESSFULLY ===');
      debugPrint('Certificate size: ${certificateBytes.length} bytes');
      debugPrint('Certificate saved to: $filePath');

      return {
        'isBase64': false,
        'filePath': filePath,
        'message': 'Certificate downloaded successfully for ${student.name}',
        'studentName': student.name,
        'canShare': true,
      };
    } catch (e) {
      debugPrint('=== CERTIFICATE GENERATION ERROR ===');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('Error Message: $e');
      throw Exception('Failed to generate certificate: $e');
    }
  }

  // Generate certificate using Flutter Canvas for better text rendering
  Future<Uint8List> _generateCertificateWithCanvas(
    String studentName,
  ) async {
    try {
      debugPrint('=== GENERATING CERTIFICATE WITH CANVAS ===');

      // Load the certificate template image
      debugPrint(
          'Loading certificate template from: ${ImageClass.certificate}');
      final ByteData imageData = await rootBundle.load(ImageClass.certificate);
      final Uint8List imageBytes = imageData.buffer.asUint8List();

      // Decode the image to get dimensions
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image backgroundImage = frameInfo.image;

      final int width = backgroundImage.width;
      final int height = backgroundImage.height;

      debugPrint('Certificate dimensions: ${width}x$height');

      // Create a picture recorder and canvas
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Draw the background image
      canvas.drawImage(backgroundImage, Offset.zero, Paint());

      // Set up text style for student name only
      final TextStyle nameStyle = TextStyle(
        fontSize: 80,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: 'serif',
      );

      // Create text painter for student name only
      final TextPainter namePainter = TextPainter(
        text: TextSpan(text: studentName.toUpperCase(), style: nameStyle),
        textDirection: TextDirection.ltr,
      );

      // Layout the text
      namePainter.layout();

      // Calculate position - center horizontally and position higher than middle
      final double centerX = width / 2;
      final double nameY =
          height * 0.45; // Position higher than middle (40% from top)

      // Draw only the student name on the canvas
      namePainter.paint(
        canvas,
        Offset(centerX - (namePainter.width / 2), nameY),
      );

      // End recording and create the image
      final ui.Picture picture = recorder.endRecording();
      final ui.Image finalImage = await picture.toImage(width, height);

      // Convert to bytes
      final ByteData? byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Failed to convert certificate to bytes');
      }

      debugPrint('Certificate generated with Canvas successfully');
      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error generating certificate with Canvas: $e');
      throw Exception('Failed to generate certificate: $e');
    }
  }

  // Add getter for certificate availability
  bool get canDownloadCertificate {
    if (_quizHistory.isEmpty) return false;

    final latestSession = _quizHistory.first;
    return latestSession.isCompleted &&
        latestSession.correctAnswers != null &&
        latestSession.isSubmitted;
  }

  // Get remaining time in minutes
  int getRemainingTime() {
    if (_quizConfig == null) return 0;

    final now = DateTime.now();
    final end = _quizConfig!.endDate.toLocal();
    return end.difference(now).inMinutes;
  }

  // Get formatted remaining time
  String getFormattedRemainingTime() {
    final minutes = getRemainingTime();
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '$hours hr $remainingMinutes min remaining';
    } else {
      return '$remainingMinutes min remaining';
    }
  }

  // Save certificate to downloads folder
  Future<String> _saveCertificateToDownloads(
      Uint8List certificateBytes, String studentName) async {
    try {
      debugPrint('=== SAVING CERTIFICATE TO DOWNLOADS ===');

      // Get the downloads directory
      Directory? downloadsDirectory;

      if (Platform.isAndroid) {
        // For Android, use the Downloads directory
        downloadsDirectory = Directory('/storage/emulated/0/Download');
        if (!await downloadsDirectory.exists()) {
          // Fallback to external storage directory
          downloadsDirectory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        // For iOS, use the documents directory and make it accessible via Files app
        downloadsDirectory = await getApplicationDocumentsDirectory();

        // Create a subdirectory for certificates that will be visible in Files app
        final certificatesDir =
            Directory('${downloadsDirectory.path}/Certificates');
        if (!await certificatesDir.exists()) {
          await certificatesDir.create(recursive: true);
        }
        downloadsDirectory = certificatesDir;
      } else {
        // For other platforms, use downloads directory
        downloadsDirectory = await getDownloadsDirectory();
      }

      if (downloadsDirectory == null) {
        throw Exception('Could not access downloads directory');
      }

      // Create filename with timestamp to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'Zaitoon_Certificate_${studentName.replaceAll(' ', '_')}_$timestamp.png';
      final filePath = '${downloadsDirectory.path}/$fileName';

      // Write the file
      final file = File(filePath);
      await file.writeAsBytes(certificateBytes);

      // Show download notification
      await _showDownloadNotification(fileName, filePath);

      // For iOS, automatically trigger share to allow user to save to Files app or Photos
      if (Platform.isIOS) {
        debugPrint(
            'iOS detected - triggering automatic share for better user experience');
        // Small delay to ensure file is written
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          await Share.shareXFiles(
            [XFile(filePath)],
            text: 'My Zaitoon Quiz Certificate',
            subject: 'Zaitoon Quiz Certificate',
          );
        } catch (e) {
          debugPrint('Error auto-sharing on iOS: $e');
          // Continue even if share fails
        }
      }

      debugPrint('Certificate saved successfully to: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error saving certificate: $e');
      throw Exception('Failed to save certificate: $e');
    }
  }

  // Open certificate file with system default app
  Future<void> _openCertificateFile(String filePath) async {
    try {
      debugPrint('=== OPENING CERTIFICATE FILE ===');
      debugPrint('File path: $filePath');

      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('Certificate file not found: $filePath');
        return;
      }

      // Use OpenFilex to open the file with default app
      final result = await OpenFilex.open(filePath);

      debugPrint('OpenFilex result: ${result.type}');
      debugPrint('OpenFilex message: ${result.message}');

      if (result.type == ResultType.done) {
        debugPrint('Certificate opened successfully in image viewer');
      } else if (result.type == ResultType.noAppToOpen) {
        debugPrint('No app found to open image file, falling back to share');
        await shareCertificate(filePath);
      } else if (result.type == ResultType.permissionDenied) {
        debugPrint('Permission denied to open file, falling back to share');
        await shareCertificate(filePath);
      } else if (result.type == ResultType.error) {
        debugPrint(
            'Error opening file: ${result.message}, falling back to share');
        await shareCertificate(filePath);
      } else {
        debugPrint(
            'Unknown result type: ${result.type}, falling back to share');
        await shareCertificate(filePath);
      }
    } catch (e) {
      debugPrint('Error opening certificate file: $e');
      // Fallback: try to share the file instead
      try {
        await shareCertificate(filePath);
      } catch (shareError) {
        debugPrint('Error sharing certificate as fallback: $shareError');
      }
    }
  }

  // Share certificate file
  Future<void> shareCertificate(String filePath) async {
    try {
      debugPrint('=== SHARING CERTIFICATE ===');
      debugPrint('File path: $filePath');

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Certificate file not found');
      }

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'My Zaitoon Quiz Certificate',
        subject: 'Zaitoon Quiz Certificate',
      );

      debugPrint('Certificate shared successfully');
    } catch (e) {
      debugPrint('Error sharing certificate: $e');
      throw Exception('Failed to share certificate: $e');
    }
  }

  // Public method to open certificate file (can be called from UI)
  Future<void> openCertificate(String filePath) async {
    await _openCertificateFile(filePath);
  }

  // Add setter for student mobile
  void setStudentMobile(String mobile) {
    _studentMobile = mobile;
  }

  @override
  void dispose() {
    debugPrint('=== DISPOSING QUIZ PROVIDER ===');
    debugPrint('Cancelling config check timer');
    _configCheckTimer?.cancel();
    debugPrint('Cancelling quiz timer');
    _quizTimer?.cancel();
    debugPrint('Provider disposal complete');
    super.dispose();
  }
}
