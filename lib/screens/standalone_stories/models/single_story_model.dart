// To parse this JSON data, do
//
//     final singleStoryModel = singleStoryModelFromJson(jsonString);

import 'dart:convert';

SingleStoryModel singleStoryModelFromJson(String str) =>
    SingleStoryModel.fromJson(json.decode(str));

String singleStoryModelToJson(SingleStoryModel data) =>
    json.encode(data.toJson());

class SingleStoryModel {
  final List<Datum> data;

  SingleStoryModel({
    required this.data,
  });

  factory SingleStoryModel.fromJson(Map<String, dynamic> json) =>
      SingleStoryModel(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  final String coverImage;
  final String description;
  final int id;
  final String readTime;
  final String storyFileEn;
  final String storyFileMl;
  final String storyTitleEn;
  final String storyTitleMl;
  final String tag;
  bool? isHighlighted;
  dynamic enBanner;
  dynamic mlBanner;
  Datum({
    required this.coverImage,
    required this.description,
    required this.id,
    required this.readTime,
    required this.storyFileEn,
    required this.storyFileMl,
    required this.storyTitleEn,
    required this.storyTitleMl,
    required this.tag,
    this.isHighlighted,
    this.enBanner,
    this.mlBanner,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        coverImage: json["cover_image"],
        description: json["description"],
        id: json["id"],
        readTime: json["read_time"],
        storyFileEn: json["story_file_en"],
        storyFileMl: json["story_file_ml"],
        storyTitleEn: json["story_tile_en"],
        storyTitleMl: json["story_title_ml"],
        tag: json["tag"],
        isHighlighted: json["isHighlighted"],
        enBanner: json["en_banner"],
        mlBanner: json["ml_banner"],
      );

  Map<String, dynamic> toJson() => {
        "cover_image": coverImage,
        "description": description,
        "id": id,
        "read_time": readTime,
        "story_file_en": storyFileEn,
        "story_file_ml": storyFileMl,
        "story_tile_en": storyTitleEn,
        "story_title_ml": storyTitleMl,
        "tag": tag,
        "isHighlighted": isHighlighted,
        "en_banner": enBanner,
        "ml_banner": mlBanner,
      };
}
