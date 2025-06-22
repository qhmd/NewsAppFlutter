import 'package:hive/hive.dart';

part 'bookmark.g.dart';

@HiveType(typeId: 0)
class Bookmark extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String multimedia;

  @HiveField(2)
  String title;

  @HiveField(3)
  String source;

  @HiveField(4)
  String date;
  
  @HiveField(5)
  String url;

  Bookmark({required this.id,required this.multimedia, required this.title, required this.source, required this.date, required this.url});

}
