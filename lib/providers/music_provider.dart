import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mp3_clone/models/music.dart';

class MusicProvider {
  static final MusicProvider instance = MusicProvider._internal();
  MusicProvider._internal();

  final List<Music> _list = [];

  List<Music> get list => [..._list];
  Music getByID(String id) => _list.firstWhere((music) => music.id == id);

  Future<void> fetchAndSetData() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final querySnapshot = await firestore.collection('musics').get();
      final queryDocumentSnapshots = querySnapshot.docs;

      _list.clear();
      for (var qds in queryDocumentSnapshots) {
        try {
          final music = Music.fromMap(qds.data(), qds.id);
          _list.add(music);
        } catch (error) {
          print('<<Exception-AllMusics-fetchAndSetData-${qds.id}>>' +
              error.toString());
        }
      }
    } catch (error) {
      print('<<Exception-AllMusics-fetchAndSetData>> ' + error.toString());
    }
  }

  // Phương thức tìm kiếm bài nhạc
  List<Music> search(String keyword) {
    List<Music> result = [];
    keyword.replaceAll(' ', '');
    for (var music in list) {
      var encodeString = music.title + music.artists + music.title;
      encodeString.replaceAll(' ', '');

      if (encodeString.contains(RegExp(keyword, caseSensitive: false))) {
        result.add(music);
      }
    }
    return result;
  }

  // Phương thức sắp xếp bài nhạc (Chưa thực hiện)
  List<Music> getSorted() {
    // TODO: Sắp xếp giảm dần dùng playing_log
    return list;
  }

  // Phương thức tạo bài nhạc và lưu vào Firebase
  Future<void> addMusic(Music music) async {
    final firestore = FirebaseFirestore.instance;
    try {
      // Thêm bài nhạc vào Firestore
      final docRef = await firestore.collection('musics').add(music.toMap());

      // Cập nhật lại ID bài nhạc sau khi lưu vào Firebase
      final newMusic = music.copyWith(id: docRef.id);

      // Thêm bài nhạc vào danh sách trong provider
      _list.add(newMusic);

      // Nếu có thể, bạn có thể gọi setState để cập nhật UI hoặc notify listeners nếu đang sử dụng `ChangeNotifier`
    } catch (error) {
      print('<<Exception-MusicProvider-addMusic>> ' + error.toString());
    }
  }
}
