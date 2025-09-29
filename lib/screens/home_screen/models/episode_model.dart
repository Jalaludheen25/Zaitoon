// To parse this JSON data, do
//
//     final episodeModel = episodeModelFromJson(jsonString);

import 'dart:convert';

EpisodeModel episodeModelFromJson(String str) =>
    EpisodeModel.fromJson(json.decode(str));

String episodeModelToJson(EpisodeModel data) => json.encode(data.toJson());

class EpisodeModel {
  List<EpisodeData>? data;

  EpisodeModel({
    this.data,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) => EpisodeModel(
        data: json["data"] == null
            ? []
            : List<EpisodeData>.from(
                json["data"]!.map((x) => EpisodeData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class EpisodeData {
  String? adBanner;
  String? coverImage;
  String? hinBanner;
  String? hinStoryFile;
  String? hinTitle;
  int? id;
  bool? isHighlighted;
  String? mlBanner;
  String? mlStoryFile;
  String? mlTitle;
  String? readMinutes;
  int? season;
  int? story;
  String? storyFile;
  String? storyTile;
  String? uploadDate;
  String? urBanner;
  String? urStoryFile;
  String? urTitle;
  bool? visibilityStatus;

  EpisodeData({
    this.adBanner,
    this.coverImage,
    this.hinBanner,
    this.hinStoryFile,
    this.hinTitle,
    this.id,
    this.isHighlighted,
    this.mlBanner,
    this.mlStoryFile,
    this.mlTitle,
    this.readMinutes,
    this.season,
    this.story,
    this.storyFile,
    this.storyTile,
    this.uploadDate,
    this.urBanner,
    this.urStoryFile,
    this.urTitle,
    this.visibilityStatus,
  });

  factory EpisodeData.fromJson(Map<String, dynamic> json) => EpisodeData(
        adBanner: json["ad_banner"],
        coverImage: json["cover_image"],
        hinBanner: json["hin_banner"],
        hinStoryFile: json["hin_story_file"],
        hinTitle: json["hin_title"],
        id: json["id"],
        isHighlighted: json["isHighlighted"],
        mlBanner: json["ml_banner"],
        mlStoryFile: json["ml_story_file"],
        mlTitle: json["ml_title"],
        readMinutes: json["read_minutes"],
        season: json["season"],
        story: json["story"],
        storyFile: json["story_file"],
        storyTile: json["story_tile"],
        uploadDate: json["upload_date"],
        urBanner: json["ur_banner"],
        urStoryFile: json["ur_story_file"],
        urTitle: json["ur_title"],
        visibilityStatus: json["visibility_status"],
      );

  Map<String, dynamic> toJson() => {
        "ad_banner": adBanner,
        "cover_image": coverImage,
        "hin_banner": hinBanner,
        "hin_story_file": hinStoryFile,
        "hin_title": hinTitle,
        "id": id,
        "isHighlighted": isHighlighted,
        "ml_banner": mlBanner,
        "ml_story_file": mlStoryFile,
        "ml_title": mlTitle,
        "read_minutes": readMinutes,
        "season": season,
        "story": story,
        "story_file": storyFile,
        "story_tile": storyTile,
        "upload_date": uploadDate,
        "ur_banner": urBanner,
        "ur_story_file": urStoryFile,
        "ur_title": urTitle,
        "visibility_status": visibilityStatus,
      };
}
