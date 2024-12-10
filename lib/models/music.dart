import 'package:uuid/uuid.dart';

class Music {
  final String id;
  final String title;
  final String artists;
  final String imageUrl;
  final String thumbnailUrl;
  final String audioUrl;
  final int duration;
  String? lyrics;

  Music({
    required this.id,
    required this.title,
    required this.artists,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.audioUrl,
    required this.duration,
    this.lyrics,
  });

  factory Music.fromMap(Map<String, dynamic> map, String id) {
    String? lyrics = map['lyrics'];
    if (lyrics != null) {
      lyrics = lyrics.replaceAll('\\n', '\n');
    }

    return Music(
      id: id,
      title: map['title'],
      artists: map['artists'],
      imageUrl: map['imageUrl'],
      thumbnailUrl: map['thumbnailUrl'],
      audioUrl: map['audioUrl'],
      duration: map['duration'],
      lyrics: lyrics,
    );
  }
  static String generateId() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  Map<String, Object> toMap() {
    var map = {
      'title': title,
      'artists': artists,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'audioUrl': audioUrl,
      'duration': duration,
    };
    if (lyrics != null) {
      map['lyrics'] = lyrics!;
    }
    return map;
  }

  // Phương thức copyWith để tạo một bản sao với ID mới
  Music copyWith({
    String? id,
    String? title,
    String? artists,
    String? imageUrl,
    String? thumbnailUrl,
    String? audioUrl,
    int? duration,
    String? lyrics,
  }) {
    return Music(
      id: id ?? this.id,
      title: title ?? this.title,
      artists: artists ?? this.artists,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      lyrics: lyrics ?? this.lyrics,
    );
  }
}
