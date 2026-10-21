import 'package:flutter/material.dart';

import '../database/movie_database.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import 'detail_screen.dart';
import 'history_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _service = TmdbService();
  List<SearchResult> _results = [];
  String _mediaType = 'movie';
  String? _message;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final title = _titleController.text.trim();
    final year = _yearController.text.trim();
    if (title.isEmpty) {
      setState(() => _message = 'Escribe un título para buscar.');
      return;
    }
    if (year.isNotEmpty && (year.length != 4 || int.tryParse(year) == null)) {
      setState(() => _message = 'El año debe tener 4 números.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _message = null;
      _results = [];
    });
    try {
      final results = await _service.search(
        query: title,
        mediaType: _mediaType,
        year: year,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        _message = results.isEmpty ? 'No se encontraron resultados.' : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = _cleanError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openDetails(SearchResult result) async {
    setState(() => _isLoading = true);
    try {
      final movie = await _service.getDetails(result);
      await MovieDatabase.instance.save(movie);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => DetailScreen(movie: movie)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_cleanError(error))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador TMDB'),
        actions: [
          IconButton(
            tooltip: 'Historial de búsqueda',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
            ),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchForm(
            titleController: _titleController,
            yearController: _yearController,
            mediaType: _mediaType,
            isLoading: _isLoading,
            onTypeChanged: (value) => setState(() => _mediaType = value),
            onSearch: _search,
          ),
          if (_isLoading) const LinearProgressIndicator(minHeight: 3),
          Expanded(
            child: _results.isEmpty
                ? _SearchMessage(message: _message)
                : _ResultsList(results: _results, onTap: _openDetails),
          ),
        ],
      ),
    );
  }
}

class _SearchForm extends StatelessWidget {
  const _SearchForm({
    required this.titleController,
    required this.yearController,
    required this.mediaType,
    required this.isLoading,
    required this.onTypeChanged,
    required this.onSearch,
  });

  final TextEditingController titleController;
  final TextEditingController yearController;
  final String mediaType;
  final bool isLoading;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xffe4efec),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'movie',
                    icon: Icon(Icons.movie_outlined),
                    label: Text('Películas'),
                  ),
                  ButtonSegment(
                    value: 'tv',
                    icon: Icon(Icons.tv),
                    label: Text('Series'),
                  ),
                ],
                selected: {mediaType},
                onSelectionChanged: isLoading
                    ? null
                    : (selection) => onTypeChanged(selection.first),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ejemplo: Avengers',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (_) => onSearch(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: yearController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        labelText: 'Año (opcional)',
                        hintText: '2019',
                        counterText: '',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      onSubmitted: (_) => onSearch(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: isLoading ? null : onSearch,
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_movies_outlined,
              size: 76,
              color: Colors.grey,
            ),
            const SizedBox(height: 14),
            Text(
              message ?? 'Busca una película o serie por título y año.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.results, required this.onTap});

  final List<SearchResult> results;
  final ValueChanged<SearchResult> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Card(
          child: ListTile(
            minTileHeight: 94,
            leading: _ResultPoster(path: result.posterPath),
            title: Text(
              result.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(result.year),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onTap(result),
          ),
        );
      },
    );
  }
}

class _ResultPoster extends StatelessWidget {
  const _ResultPoster({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final placeholder = const SizedBox(
      width: 54,
      height: 76,
      child: ColoredBox(color: Color(0xffdfe7e5), child: Icon(Icons.movie)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: path == null
          ? placeholder
          : Image.network(
              'https://image.tmdb.org/t/p/w185$path',
              width: 54,
              height: 76,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => placeholder,
            ),
    );
  }
}
