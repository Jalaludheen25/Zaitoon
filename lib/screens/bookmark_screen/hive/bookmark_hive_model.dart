// bookmark_hive_model.dart
import 'package:hive/hive.dart';

part 'bookmark_hive_model.g.dart'; // Updated part directive

@HiveType(typeId: 0)
class BookmarkModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String thumbnail;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String fileUrl;

  @HiveField(4)
  final String tag;

  BookmarkModel({
    required this.id,
    required this.thumbnail,
    required this.title,
    required this.fileUrl,
    required this.tag,
  });
}
