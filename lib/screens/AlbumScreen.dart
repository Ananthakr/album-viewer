import 'package:album_viewer/bloc/events.dart';
import 'package:album_viewer/bloc/logic.dart';
import 'package:album_viewer/bloc/states.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    context.read<AlbumBloc>().add(FetchAlbums());
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
        bucket: _bucket,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Albums"),
            actions: [
              TextButton(
                  onPressed: () {
                    context.read<AlbumBloc>().add(ClearCache());
                    context.read<AlbumBloc>().add(FetchAlbums());
                  },
                  child: const Text("Clear cache"))
            ],
          ),
          body: BlocBuilder<AlbumBloc, AlbumState>(
            builder: (context, state) {
              if (state is AlbumLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AlbumLoaded) {
                return ListView.builder(
                  itemCount: state.albums.length * 1000,
                  itemBuilder: (context, index) {
                    // get the cyclic index
                    final cyclicAlbumIndex = index % state.albums.length;
                    final album = state.albums[cyclicAlbumIndex];
                    final photos = state.albumPhotos[album.id] ?? [];

                    return Column(
                      children: [
                        Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  album.title,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis),
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            key: PageStorageKey('album_$index'),
                            scrollDirection: Axis.horizontal,
                            itemCount: photos.length * 5000,
                            itemBuilder: (context, index) {
                              final cyclicPhotosIndex = index % photos.length;
                              return Container(
                                  padding: const EdgeInsets.all(4),
                                  child: CachedNetworkImage(
                                    imageUrl: photos[cyclicPhotosIndex].url,
                                    placeholder: (context, url) =>
                                        const SizedBox(
                                            height: 150,
                                            width: 150,
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ))),
                                    errorWidget: (context, url, error) =>
                                        const SizedBox(
                                            height: 150,
                                            width: 150,
                                            child: Icon(Icons.error)),
                                  ));
                            },
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 16))
                      ],
                    );
                  },
                );
              } else {
                return const Center(child: Text("Error loading albums"));
              }
            },
          ),
        ));
  }
}
