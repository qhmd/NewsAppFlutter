import 'package:flutter/material.dart';
import '../../core/constants/Api/news.dart';

class NewsProvider with ChangeNotifier {
  List<News> _news = [];
  bool _loading = false;
  int _offset = 0;
  bool _hasMore = true;

  final getRandomNewsObj = NewsService();
  List<News> get news => _news;
  bool get loading => _loading;
  bool get hasMore => _hasMore;

  Future<void> fetchNewsProv() async {
  debugPrint('masih ada  $hasMore');
    if (_loading || !_hasMore) return;
    _loading = true;
    notifyListeners();

    try {
      print("isi offset ${_offset}");
      final newArticlesRaw = await getRandomNewsObj.fetchNews(_offset);
      print("isi news article rat ${newArticlesRaw}");
      final newArticles = newArticlesRaw.where((item) => item.isValid).toList();
      debugPrint("isi newArtikel ${newArticles.length}");
      _news.addAll(newArticles);
      _offset += 20;
      _hasMore = newArticlesRaw.length == 20;
      debugPrint("dikesekusi $_hasMore");
    } catch (e) {
      debugPrint('Error fetch news: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshRandom() async {
  debugPrint('Fetching from offset $_offset');

    _loading = true;
    notifyListeners();

    try {
      final randomOffset = getRandomNewsObj.getRandomOffset();
      final randomArticles = await getRandomNewsObj.getRandomNews();
      _news = randomArticles;
      _offset = randomOffset;
      _hasMore = randomArticles.length == 20;
    } catch (e) {
      debugPrint('Failed to refresh: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
