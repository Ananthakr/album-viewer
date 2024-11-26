import 'dart:convert';
import 'package:album_viewer/storage/database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:album_viewer/bloc/events.dart';
import 'package:album_viewer/bloc/states.dart';
import 'package:album_viewer/models/album.dart';
import 'package:album_viewer/models/photo.dart';

class AlbumRepository {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;

  Future<List<Album>> fetchAlbums() async {
    // Check for locally cached albums
    final cachedAlbums = await databaseHelper.fetchAlbums();
    if (cachedAlbums.isNotEmpty) {
      return cachedAlbums;
    }

    // Fetch from API if no local data
    // Fetch only data for userId `1` to avoid long list of data
    final response = await http
        .get(Uri.parse("https://jsonplaceholder.typicode.com/albums?userId=1"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final albums = data.map((json) => Album.fromJson(json)).toList();

      // Save to local database
      await databaseHelper.insertAlbums(albums);

      return albums;
    } else {
      throw Exception("Failed to fetch albums");
    }
  }

  Future<List<Photo>> fetchPhotos(int albumId) async {
    // Check for locally cached photos
    final cachedPhotos = await databaseHelper.fetchPhotos(albumId);
    if (cachedPhotos.isNotEmpty) {
      return cachedPhotos;
    }

    // Fetch from API if no local data
    final response = await http.get(Uri.parse(
        "https://jsonplaceholder.typicode.com/photos?albumId=$albumId&userId=1"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final photos = data.map((json) => Photo.fromJson(json)).toList();

      // Save to local database
      await databaseHelper.insertPhotos(photos);

      return photos;
    } else {
      throw Exception("Failed to fetch photos");
    }
  }

  void clearCache() async {
    await databaseHelper.clearData();
  }
}

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final AlbumRepository albumRepository;

  AlbumBloc({required this.albumRepository}) : super(AlbumInitial()) {
    on<FetchAlbums>((event, emit) async {
      emit(AlbumLoading());
      try {
        final albums = await albumRepository.fetchAlbums();
        final albumPhotos = <int, List<Photo>>{};

        for (final album in albums) {
          final photos = await albumRepository.fetchPhotos(album.id);
          albumPhotos[album.id] = photos;
        }

        emit(AlbumLoaded(albums, albumPhotos));
      } catch (e) {
        emit(AlbumError("Failed to loads albums."));
      }
    });

    on<ClearCache>((event, emit) {
      albumRepository.clearCache();
    });
  }
}
