import 'package:uuid/uuid.dart';

import '../providers/music_provider.dart';
import 'music.dart';

class Playlist {
  final String id;
  String title;
  String? imageUrl;
  final List<String> musicIDs;

  Playlist({
    required this.id,
    required this.title,
    this.imageUrl,
    List<String>? musicIDs,
  }) : musicIDs = musicIDs ?? [];

  // Chuyển đổi từ Map (Firebase)
  factory Playlist.fromMap(Map<String, dynamic> data, String id) {
    return Playlist(
      id: id,
      title: data['title'],
      imageUrl: data['imageUrl'],
      musicIDs: List<String>.from(data['musicIDs'] ?? []), // Khởi tạo musicIDs mặc định
    );
  }

  factory Playlist.fromMapFirebase(Map<String, dynamic> map, String id) {
    return Playlist(
      id: id,
      title: map['title'],
      imageUrl: map['imageUrl'],
      musicIDs:
          (map['musicIDs'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  static String generateId() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  // Chuyển đổi sang Map để lưu vào Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'musicIDs': musicIDs,
    };
  }

  Future<List<Music>> getMusicList() async {
    List<Music> result = [];
    for (var musicId in musicIDs) {
      result.add(MusicProvider.instance.getByID(musicId));
    }
    return result;
  }

  Music getMusicAtIndex(int index) {
    final musicId = musicIDs[index];
    return MusicProvider.instance.getByID(musicId);
  }
}
