// To parse this JSON data, do
//
//     final storyModel = storyModelFromJson(jsonString);

import 'dart:convert';

StoryModel storyModelFromJson(String str) =>
    StoryModel.fromJson(json.decode(str));

String storyModelToJson(StoryModel data) => json.encode(data.toJson());

class StoryModel {
  final List<StoryData> data;

  StoryModel({
    required this.data,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) => StoryModel(
        data: List<StoryData>.from(
            json["data"].map((x) => StoryData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class StoryData {
  final int id;
  final String title;
  final String thumbnail;
  final String storyFile;

  StoryData({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.storyFile,
  });

  factory StoryData.fromJson(Map<String, dynamic> json) => StoryData(
        id: json["id"],
        title: json["Title"],
        thumbnail: json["thumbnail"],
        storyFile: json["story_file"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "Title": title,
        "thumbnail": thumbnail,
        "story_file": storyFile,
      };
}
