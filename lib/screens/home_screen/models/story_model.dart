// To parse this JSON data, do
//
//     final storyModel = storyModelFromJson(jsonString);

import 'dart:convert';

StoryModel storyModelFromJson(String str) => StoryModel.fromJson(json.decode(str));

String storyModelToJson(StoryModel data) => json.encode(data.toJson());

class StoryModel {
    List<StoryData>? data;

    StoryModel({
        this.data,
    });

    factory StoryModel.fromJson(Map<String, dynamic> json) => StoryModel(
        data: json["data"] == null ? [] : List<StoryData>.from(json["data"]!.map((x) => StoryData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class StoryData {
    String? coverimage;
    String? description;
    int? id;
    String? mlDescription;
    String? mlTitle;
    String? name;
    String? tag;

    StoryData({
        this.coverimage,
        this.description,
        this.id,
        this.mlDescription,
        this.mlTitle,
        this.name,
        this.tag,
    });

    factory StoryData.fromJson(Map<String, dynamic> json) => StoryData(
        coverimage: json["coverimage"],
        description: json["description"],
        id: json["id"],
        mlDescription: json["ml_description"],
        mlTitle: json["ml_title"],
        name: json["name"],
        tag: json["tag"],
    );

    Map<String, dynamic> toJson() => {
        "coverimage": coverimage,
        "description": description,
        "id": id,
        "ml_description": mlDescription,
        "ml_title": mlTitle,
        "name": name,
        "tag": tag,
    };
}
