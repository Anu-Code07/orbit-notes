import 'dart:convert';

import 'package:http/http.dart' as http;

/// Free place photos via Wikipedia page summaries (no API key).
class PlaceImageService {
  PlaceImageService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, String?> _cache = {};

  Future<String?> imageUrlFor(String query) async {
    final key = query.trim().toLowerCase();
    if (key.isEmpty) return null;
    if (_cache.containsKey(key)) return _cache[key];

    try {
      final searchUri = Uri.https('en.wikipedia.org', '/w/api.php', {
        'action': 'query',
        'list': 'search',
        'srsearch': query,
        'srlimit': '1',
        'format': 'json',
        'origin': '*',
      });
      final searchResponse = await _client
          .get(
            searchUri,
            headers: {'User-Agent': 'OrbitNotes/1.0 (travel journal)'},
          )
          .timeout(const Duration(seconds: 10));
      if (searchResponse.statusCode < 200 || searchResponse.statusCode >= 300) {
        _cache[key] = null;
        return null;
      }
      final searchJson = jsonDecode(searchResponse.body) as Map<String, dynamic>;
      final results = (searchJson['query'] as Map?)?['search'] as List?;
      if (results == null || results.isEmpty) {
        _cache[key] = null;
        return null;
      }
      final title = '${(results.first as Map)['title']}'.trim();
      if (title.isEmpty) {
        _cache[key] = null;
        return null;
      }

      final summaryUri = Uri.https(
        'en.wikipedia.org',
        '/api/rest_v1/page/summary/${Uri.encodeComponent(title)}',
      );
      final summaryResponse = await _client
          .get(
            summaryUri,
            headers: {'User-Agent': 'OrbitNotes/1.0 (travel journal)'},
          )
          .timeout(const Duration(seconds: 10));
      if (summaryResponse.statusCode < 200 ||
          summaryResponse.statusCode >= 300) {
        _cache[key] = null;
        return null;
      }
      final summary = jsonDecode(summaryResponse.body) as Map<String, dynamic>;
      final thumb = summary['thumbnail'];
      final original = summary['originalimage'];
      final url = (thumb is Map ? thumb['source'] : null) ??
          (original is Map ? original['source'] : null);
      final resolved = url is String && url.isNotEmpty ? url : null;
      _cache[key] = resolved;
      return resolved;
    } catch (_) {
      _cache[key] = null;
      return null;
    }
  }
}
