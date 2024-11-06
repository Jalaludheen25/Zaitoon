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
  final String coverimage;
  final String description;
  final String name;
  final String tag;

  StoryData({
    required this.id,
    required this.coverimage,
    required this.description,
    required this.name,
    required this.tag,
  });

  factory StoryData.fromJson(Map<String, dynamic> json) => StoryData(
        id: json["id"],
        coverimage: json["coverimage"],
        description: json["description"],
        name: json["name"],
        tag: json["tag"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "coverimage": coverimage,
        "description": description,
        "name": name,
        "tag": tag,
      };
}
