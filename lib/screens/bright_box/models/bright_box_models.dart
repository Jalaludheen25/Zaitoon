class BrightBoxCategory {
  final int id;
  final String catTitleEn;
  final String catTitleMl;
  final String catTitleHi;
  final String catTitleUr;

  BrightBoxCategory({
    required this.id,
    required this.catTitleEn,
    required this.catTitleMl,
    required this.catTitleHi,
    required this.catTitleUr,
  });

  factory BrightBoxCategory.fromJson(Map<String, dynamic> json) {
    return BrightBoxCategory(
      id: json['id'] ?? 0,
      catTitleEn: json['cat_title_en'] ?? '',
      catTitleMl: json['cat_title_ml'] ?? '',
      catTitleHi: json['cat_title_hin'] ?? '',
      catTitleUr: json['cat_title_ur'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cat_title_en': catTitleEn,
      'cat_title_ml': catTitleMl,
      'cat_title_hin': catTitleHi,
      'cat_title_ur': catTitleUr,
    };
  }
}

class BrightBoxSubcategory {
  final int id;
  final String dateCreated;
  final String subcatTitleEn;
  final String subcatTitleMl;
  final String subcatTitleHi;
  final String subcatTitleUr;
  final int category;

  BrightBoxSubcategory({
    required this.id,
    required this.dateCreated,
    required this.subcatTitleEn,
    required this.subcatTitleMl,
    required this.subcatTitleHi,
    required this.subcatTitleUr,
    required this.category,
  });

  factory BrightBoxSubcategory.fromJson(Map<String, dynamic> json) {
    return BrightBoxSubcategory(
      id: json['id'] ?? 0,
      dateCreated: json['date_created'] ?? '',
      subcatTitleEn: json['subcat_title_en'] ?? '',
      subcatTitleMl: json['subcat_title_ml'] ?? '',
      subcatTitleHi: json['subcat_title_hin'] ?? '',
      subcatTitleUr: json['subcat_title_ur'] ?? '',
      category: json['category'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_created': dateCreated,
      'subcat_title_en': subcatTitleEn,
      'subcat_title_ml': subcatTitleMl,
      'subcat_title_hin': subcatTitleHi,
      'subcat_title_ur': subcatTitleUr,
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
  final String storyTitleHi;
  final String storyTitleUr;
  final String storyEn;
  final String storyMl;
  final String storyHi;
  final String storyUr;
  final int subcategory;

  BrightBoxStory({
    required this.id,
    required this.userCreated,
    required this.dateCreated,
    required this.storyTitleEn,
    required this.storyTitleMl,
    required this.storyTitleHi,
    required this.storyTitleUr,
    required this.storyEn,
    required this.storyMl,
    required this.storyHi,
    required this.storyUr,
    required this.subcategory,
  });

  factory BrightBoxStory.fromJson(Map<String, dynamic> json) {
    return BrightBoxStory(
      id: json['id'] ?? 0,
      userCreated: json['user_created'] ?? '',
      dateCreated: json['date_created'] ?? '',
      storyTitleEn: json['story_title_en'] ?? '',
      storyTitleMl: json['story_title_ml'] ?? '',
      storyTitleHi: json['story_title_hin'] ?? '',
      storyTitleUr: json['story_title_ur'] ?? '',
      storyEn: json['story_en'] ?? '',
      storyMl: json['story_ml'] ?? '',
      storyHi: json['story_hin'] ?? '',
      storyUr: json['story_ur'] ?? '',
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
      'story_title_hin': storyTitleHi,
      'story_title_ur': storyTitleUr,
      'story_en': storyEn,
      'story_ml': storyMl,
      'story_hin': storyHi,
      'story_ur': storyUr,
      'subcategory': subcategory,
    };
  }
}
