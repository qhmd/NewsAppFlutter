import 'package:flutter/material.dart';
import '../../core/constants/Api/news.dart';

class NewsProvider with ChangeNotifier {
  final Map<String, List<News>> _newsByCategory = {};
  final Map<String, bool> _loadingByCategory = {};
  final Map<String, int> _offsetByCategory = {};
  final Map<String, bool> _hasMoreByCategory = {};

  final NewsService _newsService = NewsService();

  List<News> getNews(String category) => _newsByCategory[category] ?? [];
  bool isLoading(String category) => _loadingByCategory[category] ?? false;
  bool hasMore(String category) => _hasMoreByCategory[category] ?? true;

  Future<void> fetchNews(String category) async {
    if (isLoading(category) || !hasMore(category)) return;
    _loadingByCategory[category] = true;
    notifyListeners();

    try {
      final offset = _offsetByCategory[category] ?? 0;
      final newArticlesRaw = await _newsService.fetchNews(category, offset);
      final newArticles = newArticlesRaw.where((item) => item.isValid).toList();

      _newsByCategory[category] = [...getNews(category), ...newArticles];
      _offsetByCategory[category] = offset + 20;
      _hasMoreByCategory[category] = newArticlesRaw.length == 20;
    } catch (e) {
      debugPrint('Error fetch news for $category: $e');
    } finally {
      _loadingByCategory[category] = false;
      notifyListeners();
    }
  }

  Future<void> refreshNews(String category) async {
    _loadingByCategory[category] = true;
    notifyListeners();

    try {
      final randomOffset = _newsService.getRandomOffset();
      final randomArticles = await _newsService.fetchNews(category, randomOffset);
      _newsByCategory[category] = randomArticles;
      _offsetByCategory[category] = randomOffset;
      _hasMoreByCategory[category] = randomArticles.length == 20;
    } catch (e) {
      debugPrint('Failed to refresh $category: $e');
    } finally {
      _loadingByCategory[category] = false;
      notifyListeners();
    }
  }
  void setLoading(String category, bool value) {
  _loadingByCategory[category] = value;
  notifyListeners();
}
}