import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;

class News {
  final String section;
  final String title;
  final String url;
  final String byline;
  final String abstract;
  final String published_date;
  final List multimedia;

  News({
    required this.section,
    required this.title,
    required this.url,
    required this.byline,
    required this.abstract,
    required this.published_date,
    required this.multimedia,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      section: json['section'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      byline: json['byline'] ?? '',
      abstract: json['abstract'] ?? '',
      published_date: json['published_date'] ?? '',
      multimedia: json['multimedia'] ?? [],
    );
  }

  bool get isValid =>
      abstract.isNotEmpty &&
      title.isNotEmpty &&
      byline.isNotEmpty &&
      url.isNotEmpty &&
      multimedia.length > 2 &&
      multimedia[2]['url'] != null &&
      published_date.isNotEmpty;
}

class NewsService {
  final String apiKey = "gtORzHRECZwa9jePeHX6R2a4wQfzOz5q";
  final String baseUrl =
      "https://api.nytimes.com/svc/news/v3/content/all/all.json";

  int getRandomOffset() {
    // Buat list offset: [0, 20, 40, ..., 480]
    final List<int> offsets = List.generate(25, (index) => index * 20);

    // Pilih salah satu secara acak
    final randomIndex = math.Random().nextInt(offsets.length);

    return offsets[randomIndex];
  }

  Future<List<News>> fetchNews(int offset, [int limit = 20]) async {try {
      final uri = Uri.parse('$baseUrl?limit=$limit&offset=$offset&api-key=$apiKey');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((item) => News.fromJson(item)).toList();
      } else if (response.statusCode == 429) {
        throw Exception('API limit exceeded. Try again later.');
      } else {
        throw Exception('Failed to load news: Status ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid data format from API');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  Future<List<News>> getRandomNews() async {
    final offset = getRandomOffset();
    return fetchNews(offset);
  }
}
