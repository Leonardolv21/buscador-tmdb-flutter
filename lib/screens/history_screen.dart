import 'package:flutter/material.dart';

import '../database/movie_database.dart';
import '../models/movie.dart';
import 'detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Movie>> _history;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _history = MovieDatabase.instance.getHistory();
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar historial'),
        content: const Text('¿Deseas eliminar todas las búsquedas guardadas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await MovieDatabase.instance.clearHistory();
    if (!mounted) return;
    setState(_loadHistory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de búsqueda'),
        actions: [
          IconButton(
            tooltip: 'Borrar historial',
            onPressed: _clearHistory,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: _history,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('No se pudo leer el historial.'));
          }
          final movies = snapshot.data ?? [];
          if (movies.isEmpty) {
            return const _EmptyHistory();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: movies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Card(
                child: ListTile(
                  minTileHeight: 82,
                  leading: _SmallPoster(movie: movie),
                  title: Text(
                    movie.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${movie.typeLabel} · ${movie.year}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => DetailScreen(movie: movie),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 72, color: Colors.grey),
            SizedBox(height: 12),
            Text('Todavía no buscaste ninguna película o serie.'),
          ],
        ),
      ),
    );
  }
}

class _SmallPoster extends StatelessWidget {
  const _SmallPoster({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: movie.imageUrl.isEmpty
          ? const SizedBox(
              width: 48,
              height: 68,
              child: ColoredBox(
                color: Color(0xffdfe7e5),
                child: Icon(Icons.movie),
              ),
            )
          : Image.network(
              movie.imageUrl,
              width: 48,
              height: 68,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                width: 48,
                height: 68,
                child: ColoredBox(
                  color: Color(0xffdfe7e5),
                  child: Icon(Icons.broken_image),
                ),
              ),
            ),
    );
  }
}
