import '../../data/models/bookmark.dart';
import 'package:hive_flutter/hive_flutter.dart';


bool isBookmarkedCheck(String id) {
  final box = Hive.box<Bookmark>('bookmarks');
  return box.containsKey(id);
}
