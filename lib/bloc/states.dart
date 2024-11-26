import 'package:album_viewer/models/album.dart';
import 'package:album_viewer/models/photo.dart';

abstract class AlbumState {}

class AlbumInitial extends AlbumState {}

class AlbumLoading extends AlbumState {}

class AlbumLoaded extends AlbumState {
  final List<Album> albums;
  final Map<int, List<Photo>> albumPhotos;

  AlbumLoaded(this.albums, this.albumPhotos);
}

class AlbumError extends AlbumState {
  final String message;

  AlbumError(this.message);
}
