import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search/main.dart';

void main() {
  testWidgets('muestra el formulario de búsqueda', (tester) async {
    await tester.pumpWidget(const MovieSearchApp());

    expect(find.text('Buscador TMDB'), findsOneWidget);
    expect(find.text('Título'), findsOneWidget);
    expect(find.text('Año (opcional)'), findsOneWidget);
    expect(find.text('Buscar'), findsOneWidget);
  });
}
