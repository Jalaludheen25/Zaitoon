// To parse this JSON data, do
//
//     final singleStoryModel = singleStoryModelFromJson(jsonString);

import 'dart:convert';
import 'package:flutter/foundation.dart';

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
  final String? coverImage;
  final String? description;
  final int? id;
  final String? readTime;
  final String? storyFileEn;
  final String? storyFileMl;
  final String? storyTitleEn;
  final String? storyTitleMl;
  final String? tag;
  final bool? isHighlighted;
  final dynamic enBanner;
  final dynamic mlBanner;
  
  Datum({
    this.coverImage,
    this.description,
    this.id,
    this.readTime,
    this.storyFileEn,
    this.storyFileMl,
    this.storyTitleEn,
    this.storyTitleMl,
    this.tag,
    this.isHighlighted,
    this.enBanner,
    this.mlBanner,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 Parsing story JSON keys: ${json.keys.toList()}');
    debugPrint('🔍 Raw JSON: $json');
    
    // Check each field for null values
    debugPrint('🔍 cover_image: ${json["cover_image"]} (${json["cover_image"].runtimeType})');
    debugPrint('🔍 description: ${json["description"]} (${json["description"].runtimeType})');
    debugPrint('🔍 id: ${json["id"]} (${json["id"].runtimeType})');
    debugPrint('🔍 read_time: ${json["read_time"]} (${json["read_time"].runtimeType})');
    debugPrint('🔍 story_file_en: ${json["story_file_en"]} (${json["story_file_en"].runtimeType})');
    debugPrint('🔍 story_file_ml: ${json["story_file_ml"]} (${json["story_file_ml"].runtimeType})');
    debugPrint('🔍 story_tile_en: ${json["story_tile_en"]} (${json["story_tile_en"].runtimeType})');
    debugPrint('🔍 story_title_ml: ${json["story_title_ml"]} (${json["story_title_ml"].runtimeType})');
    debugPrint('🔍 tag: ${json["tag"]} (${json["tag"].runtimeType})');
    debugPrint('🔍 isHighlighted: ${json["isHighlighted"]} (${json["isHighlighted"].runtimeType})');
    debugPrint('🔍 en_banner: ${json["en_banner"]} (${json["en_banner"].runtimeType})');
    debugPrint('🔍 ml_banner: ${json["ml_banner"]} (${json["ml_banner"].runtimeType})');
    
    return Datum(
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
  }

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
