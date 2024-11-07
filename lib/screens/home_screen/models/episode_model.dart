// To parse this JSON data, do
//
//     final episodeModel = episodeModelFromJson(jsonString);

import 'dart:convert';

EpisodeModel episodeModelFromJson(String str) => EpisodeModel.fromJson(json.decode(str));

String episodeModelToJson(EpisodeModel data) => json.encode(data.toJson());

class EpisodeModel {
    List<Datum>? data;

    EpisodeModel({
        this.data,
    });

    factory EpisodeModel.fromJson(Map<String, dynamic> json) => EpisodeModel(
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    String? coverImage;
    int? id;
    String? mlStoryFile;
    String? mlTitle;
    String? readMinutes;
    int? story;
    String? storyFile;
    String? storyTile;
    String? uploadDate;

    Datum({
        this.coverImage,
        this.id,
        this.mlStoryFile,
        this.mlTitle,
        this.readMinutes,
        this.story,
        this.storyFile,
        this.storyTile,
        this.uploadDate,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        coverImage: json["cover_image"],
        id: json["id"],
        mlStoryFile: json["ml_story_file"],
        mlTitle: json["ml_title"],
        readMinutes: json["read_minutes"],
        story: json["story"],
        storyFile: json["story_file"],
        storyTile: json["story_tile"],
        uploadDate: json["upload_date"],
    );

    Map<String, dynamic> toJson() => {
        "cover_image": coverImage,
        "id": id,
        "ml_story_file": mlStoryFile,
        "ml_title": mlTitle,
        "read_minutes": readMinutes,
        "story": story,
        "story_file": storyFile,
        "story_tile": storyTile,
        "upload_date": uploadDate,
    };
}
