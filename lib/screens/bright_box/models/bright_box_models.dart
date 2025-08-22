class BrightBoxCategory {
  final int id;
  final String catTitleEn;
  final String catTitleMl;

  BrightBoxCategory({
    required this.id,
    required this.catTitleEn,
    required this.catTitleMl,
  });

  factory BrightBoxCategory.fromJson(Map<String, dynamic> json) {
    return BrightBoxCategory(
      id: json['id'] ?? 0,
      catTitleEn: json['cat_title_en'] ?? '',
      catTitleMl: json['cat_title_ml'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cat_title_en': catTitleEn,
      'cat_title_ml': catTitleMl,
    };
  }
}

class BrightBoxSubcategory {
  final int id;
  final String dateCreated;
  final String subcatTitleEn;
  final String subcatTitleMl;
  final int category;

  BrightBoxSubcategory({
    required this.id,
    required this.dateCreated,
    required this.subcatTitleEn,
    required this.subcatTitleMl,
    required this.category,
  });

  factory BrightBoxSubcategory.fromJson(Map<String, dynamic> json) {
    return BrightBoxSubcategory(
      id: json['id'] ?? 0,
      dateCreated: json['date_created'] ?? '',
      subcatTitleEn: json['subcat_title_en'] ?? '',
      subcatTitleMl: json['subcat_title_ml'] ?? '',
      category: json['category'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_created': dateCreated,
      'subcat_title_en': subcatTitleEn,
      'subcat_title_ml': subcatTitleMl,
      'category': category,
    };
  }
}

class BrightBoxStory {
  final int id;
  final String userCreated;
  final String dateCreated;
  final String storyTitleEn;
  final String storyTitleMl;
  final String storyEn;
  final String storyMl;
  final int subcategory;

  BrightBoxStory({
    required this.id,
    required this.userCreated,
    required this.dateCreated,
    required this.storyTitleEn,
    required this.storyTitleMl,
    required this.storyEn,
    required this.storyMl,
    required this.subcategory,
  });

  factory BrightBoxStory.fromJson(Map<String, dynamic> json) {
    return BrightBoxStory(
      id: json['id'] ?? 0,
      userCreated: json['user_created'] ?? '',
      dateCreated: json['date_created'] ?? '',
      storyTitleEn: json['story_title_en'] ?? '',
      storyTitleMl: json['story_title_ml'] ?? '',
      storyEn: json['story_en'] ?? '',
      storyMl: json['story_ml'] ?? '',
      subcategory: json['subcategory'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_created': userCreated,
      'date_created': dateCreated,
      'story_title_en': storyTitleEn,
      'story_title_ml': storyTitleMl,
      'story_en': storyEn,
      'story_ml': storyMl,
      'subcategory': subcategory,
    };
  }
}