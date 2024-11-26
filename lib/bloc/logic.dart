import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:album_viewer/bloc/events.dart';
import 'package:album_viewer/bloc/states.dart';
import 'package:album_viewer/models/album.dart';
import 'package:album_viewer/models/photo.dart';

class AlbumRepository {
  Future<List<Album>> fetchAlbums() async {
    final response = await http
        .get(Uri.parse("https://jsonplaceholder.typicode.com/albums"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Album.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch albums");
    }
  }

  Future<List<Photo>> fetchPhotos(int albumId) async {
    final response = await http.get(Uri.parse(
        "https://jsonplaceholder.typicode.com/photos?albumId=$albumId"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Photo.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch photos");
    }
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
  }
}
