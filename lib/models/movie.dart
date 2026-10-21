class SearchResult {
  const SearchResult({
    required this.id,
    required this.title,
    required this.year,
    required this.posterPath,
    required this.mediaType,
  });

  final int id;
  final String title;
  final String year;
  final String? posterPath;
  final String mediaType;

  factory SearchResult.fromJson(Map<String, dynamic> json, String mediaType) {
    final date = mediaType == 'movie'
        ? json['release_date'] as String? ?? ''
        : json['first_air_date'] as String? ?? '';

    return SearchResult(
      id: json['id'] as int,
      title: mediaType == 'movie'
          ? json['title'] as String? ?? 'Sin título'
          : json['name'] as String? ?? 'Sin título',
      year: date.length >= 4 ? date.substring(0, 4) : 'Sin año',
      posterPath: json['poster_path'] as String?,
      mediaType: mediaType,
    );
  }
}

class Movie {
  const Movie({
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    required this.year,
    required this.duration,
    required this.genres,
    required this.director,
    required this.overview,
    required this.posterPath,
    required this.rating,
    required this.searchedAt,
  });

  final int tmdbId;
  final String mediaType;
  final String title;
  final String year;
  final int duration;
  final String genres;
  final String director;
  final String overview;
  final String? posterPath;
  final double rating;
  final DateTime searchedAt;

  String get imageUrl =>
      posterPath == null ? '' : 'https://image.tmdb.org/t/p/w500$posterPath';

  String get typeLabel => mediaType == 'movie' ? 'Película' : 'Serie';

  Map<String, Object?> toMap() {
    return {
      'tmdb_id': tmdbId,
      'media_type': mediaType,
      'title': title,
      'year': year,
      'duration': duration,
      'genres': genres,
      'director': director,
      'overview': overview,
      'poster_path': posterPath,
      'rating': rating,
      'searched_at': searchedAt.millisecondsSinceEpoch,
    };
  }

  factory Movie.fromMap(Map<String, Object?> map) {
    return Movie(
      tmdbId: map['tmdb_id'] as int,
      mediaType: map['media_type'] as String,
      title: map['title'] as String,
      year: map['year'] as String,
      duration: map['duration'] as int,
      genres: map['genres'] as String,
      director: map['director'] as String,
      overview: map['overview'] as String,
      posterPath: map['poster_path'] as String?,
      rating: (map['rating'] as num).toDouble(),
      searchedAt: DateTime.fromMillisecondsSinceEpoch(
        map['searched_at'] as int,
      ),
    );
  }
}
