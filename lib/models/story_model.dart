enum MediaType { image, video }

class Story {
  final int id;
  final String title;
  final String url;
  final String videoFormat;
  final String thumbnail;
  final MediaType media;
  bool isPlayed;

  Story({
    required this.id,
    required this.title,
    required this.url,
    required this.videoFormat,
    required this.thumbnail,
    required this.media,
    required this.isPlayed,
  });

  // Factory constructor to create a Story from JSON data
  factory Story.fromJson(Map<String, dynamic> json) {
    // Determine media type based on video format or image existence
    final mediaType =
        json['video-format'] != null ? MediaType.video : MediaType.image;

    return Story(
      id: json['id'],
      title: json['title'],
      url: json['video_url'],
      videoFormat: json['video-format'] ?? '',
      thumbnail: json['thumbnail'],
      media: mediaType,
      isPlayed: false,
    );
  }
}
