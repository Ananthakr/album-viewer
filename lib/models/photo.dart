class Photo {
  final int albumId;
  final String url;

  Photo({required this.albumId, required this.url});

  Map<String, dynamic> toJson() {
    return {
      'albumId': albumId,
      'url': url,
    };
  }

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      albumId: json['albumId'],
      url: json['url'],
    );
  }
}
