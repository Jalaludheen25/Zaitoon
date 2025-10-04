class OttContentModel {
  final String id;
  final String title;
  final String thumbnail;
  final String year;
  final String genre;
  final String duration;
  final String description;
  final String videoUrl;
  final DateTime addedToWatchlist;

  OttContentModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.year,
    required this.genre,
    required this.duration,
    required this.description,
    required this.videoUrl,
    required this.addedToWatchlist,
  });

  factory OttContentModel.fromJson(Map<String, dynamic> json) {
    return OttContentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      year: json['year'] ?? '',
      genre: json['genre'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      addedToWatchlist:
          DateTime.tryParse(json['addedToWatchlist'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'year': year,
      'genre': genre,
      'duration': duration,
      'description': description,
      'videoUrl': videoUrl,
      'addedToWatchlist': addedToWatchlist.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OttContentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
