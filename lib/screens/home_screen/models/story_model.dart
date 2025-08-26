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
    String? hinDescription;
    String? hinTitle;
    int? id;
    String? mlDescription;
    String? mlTitle;
    String? name;
    String? priority;
    bool? status;
    String? tag;
    String? urDescription;
    String? urTitle;

    StoryData({
        this.coverimage,
        this.description,
        this.hinDescription,
        this.hinTitle,
        this.id,
        this.mlDescription,
        this.mlTitle,
        this.name,
        this.priority,
        this.status,
        this.tag,
        this.urDescription,
        this.urTitle,
    });

    factory StoryData.fromJson(Map<String, dynamic> json) => StoryData(
        coverimage: json["coverimage"],
        description: json["description"],
        hinDescription: json["hin_description"],
        hinTitle: json["hin_title"],
        id: json["id"],
        mlDescription: json["ml_description"],
        mlTitle: json["ml_title"],
        name: json["name"],
        priority: json["priority"],
        status: json["status"],
        tag: json["tag"],
        urDescription: json["ur_description"],
        urTitle: json["ur_title"],
    );

    Map<String, dynamic> toJson() => {
        "coverimage": coverimage,
        "description": description,
        "hin_description": hinDescription,
        "hin_title": hinTitle,
        "id": id,
        "ml_description": mlDescription,
        "ml_title": mlTitle,
        "name": name,
        "priority": priority,
        "status": status,
        "tag": tag,
        "ur_description": urDescription,
        "ur_title": urTitle,
    };
}
