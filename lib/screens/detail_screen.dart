import 'package:flutter/material.dart';

import '../models/movie.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Poster(movie: movie),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text(movie.typeLabel)),
                          Chip(label: Text(movie.year)),
                          Chip(
                            avatar: const Icon(Icons.schedule, size: 18),
                            label: Text(
                              movie.duration > 0
                                  ? '${movie.duration} min'
                                  : 'Duración desconocida',
                            ),
                          ),
                          Chip(
                            avatar: const Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            ),
                            label: Text(
                              '${movie.rating.toStringAsFixed(1)}/10',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _Information(label: 'Género', value: movie.genres),
                      _Information(
                        label: movie.mediaType == 'movie'
                            ? 'Director'
                            : 'Creador / Director',
                        value: movie.director,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sinopsis',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.overview,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    if (movie.imageUrl.isEmpty) {
      return const SizedBox(
        height: 280,
        child: ColoredBox(
          color: Color(0xffdfe7e5),
          child: Center(child: Icon(Icons.movie, size: 80)),
        ),
      );
    }
    return Image.network(
      movie.imageUrl,
      height: 430,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const SizedBox(
        height: 280,
        child: ColoredBox(
          color: Color(0xffdfe7e5),
          child: Center(child: Icon(Icons.broken_image, size: 70)),
        ),
      ),
    );
  }
}

class _Information extends StatelessWidget {
  const _Information({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
