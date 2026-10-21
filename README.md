# Buscador TMDB

Aplicación Flutter para buscar películas y series, consultar su detalle y guardar
el historial de búsqueda en una base de datos SQLite local.

## Funciones

- Búsqueda por título y año opcional.
- Búsqueda separada de películas y series.
- Detalle con título, año, duración, género, director o creador, sinopsis,
  imagen y puntuación de usuarios.
- Historial local con el detalle completo disponible sin consultar otra vez la API.
- Eliminación completa del historial.

## Configurar TMDB

1. Crea una cuenta en <https://www.themoviedb.org/>.
2. Solicita una clave de API en la configuración de tu cuenta.
3. Ejecuta la aplicación pasando la clave sin guardarla en el código:

```bash
flutter run --dart-define=TMDB_API_KEY=TU_CLAVE
```

Para generar un APK:

```bash
flutter build apk --dart-define=TMDB_API_KEY=TU_CLAVE
```

## Dependencias principales

- `http`: consumo de la API de TMDB.
- `sqflite`: base de datos SQLite local.
- `path`: construcción segura de la ruta de la base de datos.
