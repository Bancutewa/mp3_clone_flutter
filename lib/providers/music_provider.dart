import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mp3_clone/models/music.dart';

class MusicProvider with ChangeNotifier {
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
      notifyListeners(); // Gọi notifyListeners() để cập nhật giao diện
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
      notifyListeners(); // Gọi notifyListeners() để cập nhật giao diện
    } catch (error) {
      print('<<Exception-MusicProvider-addMusic>> ' + error.toString());
    }
  }

  // Phương thức cập nhật bài nhạc trong Firebase
  Future<void> updateMusic(Music music) async {
    final firestore = FirebaseFirestore.instance;
    try {
      // Cập nhật bài nhạc trong Firestore
      await firestore.collection('musics').doc(music.id).update(music.toMap());

      // Cập nhật bài nhạc trong danh sách provider
      int index = _list.indexWhere((m) => m.id == music.id);
      if (index != -1) {
        _list[index] = music; // Cập nhật bài nhạc trong danh sách
        notifyListeners(); // Gọi notifyListeners() để cập nhật giao diện
      }
    } catch (error) {
      print('<<Exception-MusicProvider-updateMusic>> ' + error.toString());
    }
  }

  // Phương thức xóa bài nhạc trong Firebase
  Future<void> deleteMusic(String id) async {
    final firestore = FirebaseFirestore.instance;
    try {
      // Xóa bài nhạc khỏi Firestore
      await firestore.collection('musics').doc(id).delete();

      // Xóa bài nhạc khỏi danh sách provider
      _list.removeWhere((music) => music.id == id);
      notifyListeners(); // Gọi notifyListeners() để cập nhật giao diện
    } catch (error) {
      print('<<Exception-MusicProvider-deleteMusic>> ' + error.toString());
    }
  }

  // Lấy tất cả bài hát từ Firestore
  Future<List<Music>> getAllMusic() async {
    await fetchAndSetData();  // Đảm bảo dữ liệu đã được tải
    return list;  // Trả về danh sách bài hát đã tải
  }

  Future<void> addMusicForPlaylist(Music music) async {
  final firestore = FirebaseFirestore.instance;
  try {
    // Thêm bài nhạc vào Firestore
    final docRef = await firestore.collection('musics').add(music.toMap());

    // Cập nhật lại ID bài nhạc sau khi lưu vào Firebase
    final newMusic = music.copyWith(id: docRef.id);

    // Thêm bài nhạc vào danh sách trong provider
    _list.add(newMusic);
    notifyListeners(); // Cập nhật giao diện

    // Làm mới dữ liệu trong MusicSelectionScreen
    await fetchAndSetData();
  } catch (error) {
    print('<<Exception-MusicProvider-addMusic>> ' + error.toString());
  }
}

  Future<Music> getMusicById(String musicId) async {
    final firestore = FirebaseFirestore.instance;
    final musicDoc = await firestore.collection('music').doc(musicId).get();

    if (musicDoc.exists) {
      final musicData = musicDoc.data()!;
      return Music.fromMap(musicData, musicId);
    } else {
      throw 'Music not found';
    }
  }
}
