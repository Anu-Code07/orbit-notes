import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:orbit_notes/core/failure/failure.dart';
import 'package:orbit_notes/features/notes/domain/entities/place_search_result.dart';
import 'package:orbit_notes/features/notes/domain/repositories/place_search_repository.dart';

class NominatimPlaceSearchDataSource implements PlaceSearchRepository {
  NominatimPlaceSearchDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const _userAgent = 'OrbitNotes/1.0 (local-first travel journal)';

  @override
  Future<List<PlaceSearchResult>> search(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'addressdetails': '0',
      'limit': '10',
    });

    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'User-Agent': _userAgent,
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 429) {
        throw const UnexpectedFailure(
          'Search is busy. Wait a moment and try again.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const UnexpectedFailure('Could not search places right now.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_mapResult)
          .whereType<PlaceSearchResult>()
          .toList();
    } on Failure {
      rethrow;
    } catch (_) {
      throw const UnexpectedFailure(
        'Could not reach place search. Check your connection.',
      );
    }
  }

  PlaceSearchResult? _mapResult(Map<String, dynamic> raw) {
    final lat = double.tryParse('${raw['lat']}');
    final lon = double.tryParse('${raw['lon']}');
    if (lat == null || lon == null) return null;

    final display = '${raw['display_name'] ?? ''}'.trim();
    if (display.isEmpty) return null;

    final name = display.split(',').first.trim();
    return PlaceSearchResult(
      name: name.isEmpty ? display : name,
      displayName: display,
      latitude: lat,
      longitude: lon,
    );
  }
}
