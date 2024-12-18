class KidsContent {
  final int id;
  final String status;
  final DateTime dateCreated;
  final String contentType;
  final String title;
  final String? storyOrPoem;
  final String? drawings;
  final String kidName;
  final int kidAge;
  final String schoolName;
  final String? parentName;
  final String? parentPhoneNumber;
  final String? kidPhoto;
  final String? coverImageForPoemAndStory;
  final String? descriptionForDrawings;
  final bool highlighted;

  KidsContent({
    required this.id,
    required this.status,
    required this.dateCreated,
    required this.contentType,
    required this.title,
    this.storyOrPoem,
    this.drawings,
    required this.kidName,
    required this.kidAge,
    required this.schoolName,
    this.parentName,
    this.parentPhoneNumber,
    this.kidPhoto,
    this.coverImageForPoemAndStory,
    this.descriptionForDrawings,
    required this.highlighted,
  });

  factory KidsContent.fromJson(Map<String, dynamic> json) {
    return KidsContent(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      dateCreated: DateTime.parse(json['date_created'] ?? ''),
      contentType: json['content_type'] ?? '',
      title: json['title'] ?? '',
      storyOrPoem: json['story_or_poem'],
      drawings: json['drawings'],
      kidName: json['kid_name'] ?? '',
      kidAge: json['kid_age'] ?? 0,
      schoolName: json['school_name'] ?? '',
      parentName: json['parent_name'],
      parentPhoneNumber: json['parent_phone_number'],
      kidPhoto: json['kid_photo'],
      coverImageForPoemAndStory: json['cover_image_for_poem_and_story'],
      descriptionForDrawings: json['description_for_drawings'],
      highlighted: json['Highlighted'] ?? false,
    );
  }
}
