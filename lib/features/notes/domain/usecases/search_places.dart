import 'package:orbit_notes/features/notes/domain/entities/place_search_result.dart';
import 'package:orbit_notes/features/notes/domain/repositories/place_search_repository.dart';

class SearchPlaces {
  const SearchPlaces(this._repository);

  final PlaceSearchRepository _repository;

  Future<List<PlaceSearchResult>> call(String query) {
    final trimmed = query.trim();
    if (trimmed.length < 2) return Future.value(const []);
    return _repository.search(trimmed);
  }
}
