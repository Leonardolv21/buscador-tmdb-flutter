import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie.dart';

class TmdbService {
  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const _apiKey = String.fromEnvironment('TMDB_API_KEY');

  Future<List<SearchResult>> search({
    required String query,
    required String mediaType,
    String? year,
  }) async {
    _checkApiKey();
    final parameters = {
      'api_key': _apiKey,
      'language': 'es-ES',
      'query': query,
      'include_adult': 'false',
      if (year != null && year.isNotEmpty)
        mediaType == 'movie' ? 'year' : 'first_air_date_year': year,
    };
    final uri = Uri.parse('$_baseUrl/search/$mediaType')
        .replace(queryParameters: parameters);
    final response = await http.get(uri);
    final data = _decodeResponse(response);
    final results = data['results'] as List<dynamic>? ?? [];

    return results
        .map(
          (item) =>
              SearchResult.fromJson(item as Map<String, dynamic>, mediaType),
        )
        .toList();
  }

  Future<Movie> getDetails(SearchResult result) async {
    _checkApiKey();
    final uri = Uri.parse('$_baseUrl/${result.mediaType}/${result.id}').replace(
      queryParameters: {
        'api_key': _apiKey,
        'language': 'es-ES',
        'append_to_response': 'credits',
      },
    );
    final response = await http.get(uri);
    final data = _decodeResponse(response);

    final date = result.mediaType == 'movie'
        ? data['release_date'] as String? ?? ''
        : data['first_air_date'] as String? ?? '';
    final genreList = data['genres'] as List<dynamic>? ?? [];
    final genres = genreList
        .map((genre) => (genre as Map<String, dynamic>)['name'])
        .whereType<String>()
        .join(', ');

    return Movie(
      tmdbId: result.id,
      mediaType: result.mediaType,
      title: result.mediaType == 'movie'
          ? data['title'] as String? ?? result.title
          : data['name'] as String? ?? result.title,
      year: date.length >= 4 ? date.substring(0, 4) : result.year,
      duration: _duration(data, result.mediaType),
      genres: genres.isEmpty ? 'Sin información' : genres,
      director: _director(data, result.mediaType),
      overview: (data['overview'] as String?)?.trim().isNotEmpty == true
          ? data['overview'] as String
          : 'Sin sinopsis disponible.',
      posterPath: data['poster_path'] as String?,
      rating: (data['vote_average'] as num? ?? 0).toDouble(),
      searchedAt: DateTime.now(),
    );
  }

  int _duration(Map<String, dynamic> data, String mediaType) {
    if (mediaType == 'movie') {
      return data['runtime'] as int? ?? 0;
    }
    final runtimes = data['episode_run_time'] as List<dynamic>? ?? [];
    return runtimes.isEmpty ? 0 : runtimes.first as int;
  }

  String _director(Map<String, dynamic> data, String mediaType) {
    if (mediaType == 'tv') {
      final creators = data['created_by'] as List<dynamic>? ?? [];
      final names = creators
          .map((person) => (person as Map<String, dynamic>)['name'])
          .whereType<String>()
          .join(', ');
      if (names.isNotEmpty) return names;
    }

    final credits = data['credits'] as Map<String, dynamic>? ?? {};
    final crew = credits['crew'] as List<dynamic>? ?? [];
    final directors = crew
        .where(
          (person) => (person as Map<String, dynamic>)['job'] == 'Director',
        )
        .map((person) => (person as Map<String, dynamic>)['name'])
        .whereType<String>()
        .toSet()
        .join(', ');
    return directors.isEmpty ? 'Sin información' : directors;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) {
        throw Exception('La clave de TMDB no es válida.');
      }
      throw Exception('TMDB respondió con error ${response.statusCode}.');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _checkApiKey() {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Falta la clave de TMDB. Ejecuta con --dart-define=TMDB_API_KEY=TU_CLAVE',
      );
    }
  }
}
