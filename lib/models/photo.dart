class Photo {
  final int albumId;
  final String url;

  Photo({required this.albumId, required this.url});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      albumId: json['albumId'],
      url: json['url'],
    );
  }
}
