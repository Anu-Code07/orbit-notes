import 'package:orbit_notes/features/notes/domain/entities/place_search_result.dart';

abstract class PlaceSearchRepository {
  Future<List<PlaceSearchResult>> search(String query);
}
