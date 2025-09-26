// reading_progress_model.dart
class ReadingProgressModel {
  final String id;
  final String title;
  final String thumbnail;
  final String fileUrl;
  final String tag;
  final int currentPage;
  final int totalPages;
  final double progressPercentage;
  final DateTime lastReadAt;
  final String userId; // To associate with logged-in user

  ReadingProgressModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.fileUrl,
    required this.tag,
    required this.currentPage,
    required this.totalPages,
    required this.progressPercentage,
    required this.lastReadAt,
    required this.userId,
  });

  // Convert to Map for SharedPreferences storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'fileUrl': fileUrl,
      'tag': tag,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'progressPercentage': progressPercentage,
      'lastReadAt': lastReadAt.millisecondsSinceEpoch,
      'userId': userId,
    };
  }

  // JSON map for storage/serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'fileUrl': fileUrl,
      'tag': tag,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'progressPercentage': progressPercentage,
      'lastReadAt': lastReadAt.millisecondsSinceEpoch,
      'userId': userId,
    };
  }

  // Create from Map (from SharedPreferences)
  factory ReadingProgressModel.fromMap(Map<String, dynamic> map) {
    return ReadingProgressModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      tag: map['tag'] ?? '',
      currentPage: map['currentPage'] ?? 0,
      totalPages: map['totalPages'] ?? 0,
      progressPercentage: map['progressPercentage']?.toDouble() ?? 0.0,
      lastReadAt: DateTime.fromMillisecondsSinceEpoch(map['lastReadAt'] ?? 0),
      userId: map['userId'] ?? '',
    );
  }

  // Decode from JSON map
  factory ReadingProgressModel.fromJson(Map<String, dynamic> json) {
    return ReadingProgressModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      tag: json['tag'] ?? '',
      currentPage: json['currentPage'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      progressPercentage: (json['progressPercentage'] is int)
          ? (json['progressPercentage'] as int).toDouble()
          : (json['progressPercentage']?.toDouble() ?? 0.0),
      lastReadAt: DateTime.fromMillisecondsSinceEpoch(json['lastReadAt'] ?? 0),
      userId: json['userId'] ?? '',
    );
  }

  // Create a copy with updated values
  ReadingProgressModel copyWith({
    String? id,
    String? title,
    String? thumbnail,
    String? fileUrl,
    String? tag,
    int? currentPage,
    int? totalPages,
    double? progressPercentage,
    DateTime? lastReadAt,
    String? userId,
  }) {
    return ReadingProgressModel(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      fileUrl: fileUrl ?? this.fileUrl,
      tag: tag ?? this.tag,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'ReadingProgressModel(id: $id, title: $title, currentPage: $currentPage, totalPages: $totalPages, progressPercentage: $progressPercentage, lastReadAt: $lastReadAt, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingProgressModel &&
        other.id == id &&
        other.userId == userId;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;
}
