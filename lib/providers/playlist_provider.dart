import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mp3_clone/models/music.dart';
import 'package:mp3_clone/models/playlist.dart';

class PlaylistProvider with ChangeNotifier {
  static final PlaylistProvider instance = PlaylistProvider._internal();
  PlaylistProvider._internal();

  final List<Playlist> _playlists = [];

  List<Playlist> get playlists => [..._playlists];

  Playlist getById(String id) =>
      _playlists.firstWhere((playlist) => playlist.id == id);

  // Lấy dữ liệu danh sách Playlist từ Firebase
  Future<void> fetchAndSetPlaylists() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final querySnapshot = await firestore.collection('playlists').get();
      final queryDocumentSnapshots = querySnapshot.docs;

      _playlists.clear();
      for (var doc in queryDocumentSnapshots) {
        final playlist = Playlist.fromMap(doc.data(), doc.id);
        _playlists.add(playlist);
      }
      notifyListeners(); // Thông báo cập nhật UI
    } catch (error) {
      print('Lỗi khi lấy danh sách playlist: $error');
      throw error; // Ném lỗi để có thể xử lý khi có lỗi
    }
  }

  // Thêm Playlist
  Future<void> addPlaylist(Playlist playlist) async {
    final firestore = FirebaseFirestore.instance;
    try {
      final docRef =
          await firestore.collection('playlists').add(playlist.toMap());

      // Tạo đối tượng Playlist mới với ID từ Firebase
      final newPlaylist = Playlist(
        id: docRef.id,
        title: playlist.title,
        imageUrl: playlist.imageUrl,
        musicIDs: playlist
            .musicIDs, // musicIDs đã được khởi tạo là một danh sách trống
      );

      _playlists.add(newPlaylist);
      notifyListeners(); // Cập nhật giao diện
    } catch (error) {
      print('<<Exception-PlaylistProvider-addPlaylist>> ' + error.toString());
    }
  }

  // Cập nhật Playlist
  Future<void> updatePlaylist(Playlist playlist) async {
    final firestore = FirebaseFirestore.instance;
    try {
      await firestore
          .collection('playlists')
          .doc(playlist.id)
          .update(playlist.toMap());

      int index = _playlists.indexWhere((p) => p.id == playlist.id);
      if (index != -1) {
        _playlists[index] = playlist;
        notifyListeners(); // Cập nhật giao diện
      }
    } catch (error) {
      print(
          '<<Exception-PlaylistProvider-updatePlaylist>> ' + error.toString());
    }
  }

  // Xóa Playlist
  Future<void> deletePlaylist(String id) async {
    final firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('playlists').doc(id).delete();

      _playlists.removeWhere((playlist) => playlist.id == id);
      notifyListeners(); // Cập nhật giao diện
    } catch (error) {
      print(
          '<<Exception-PlaylistProvider-deletePlaylist>> ' + error.toString());
    }
  }

  // Thêm bài hát vào Playlist
  Future<void> addMusicToPlaylist(String playlistId, String musicId) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);

    // Nếu bài hát chưa có trong danh sách
    if (!playlist.musicIDs.contains(musicId)) {
      playlist.musicIDs.add(musicId);

      // Cập nhật lại vào Firebase
      await FirebaseFirestore.instance
          .collection('playlists')
          .doc(playlistId)
          .update({'musicIDs': playlist.musicIDs});

      notifyListeners(); // Cập nhật giao diện
    }
  }

  // Xóa bài hát khỏi Playlist
  Future<void> removeMusicFromPlaylist(
      String playlistId, String musicId) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);

    // Xóa bài hát khỏi danh sách musicIDs
    playlist.musicIDs.remove(musicId);

    // Cập nhật lại vào Firebase
    await FirebaseFirestore.instance
        .collection('playlists')
        .doc(playlistId)
        .update({'musicIDs': playlist.musicIDs});

    // Cập nhật lại danh sách bài hát sau khi xóa
    await loadMusicForPlaylist(playlistId);

    notifyListeners(); // Cập nhật giao diện
  }

  // Tải thông tin bài hát cho Playlist
  // PlaylistProvider
  Future<void> loadMusicForPlaylist(String playlistId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final playlistDoc =
          await firestore.collection('playlists').doc(playlistId).get();
      if (playlistDoc.exists) {
        final playlistData = playlistDoc.data()!;
        List<String> musicIds =
            List<String>.from(playlistData['musicIDs'] ?? []);
        List<Music> musicList = [];

        for (var musicId in musicIds) {
          final musicDoc =
              await firestore.collection('musics').doc(musicId).get();
          if (musicDoc.exists) {
            final musicData = musicDoc.data()!;
            final music = Music.fromMap(musicData, musicId);
            musicList.add(music);
          }
        }

        final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
        if (playlistIndex != -1) {
          final updatedPlaylist = Playlist(
            id: _playlists[playlistIndex].id,
            title: _playlists[playlistIndex].title,
            imageUrl: _playlists[playlistIndex].imageUrl,
            musicIDs: musicIds,
            musicList: musicList, // Cập nhật lại danh sách bài hát
          );

          _playlists[playlistIndex] = updatedPlaylist;
          notifyListeners(); // Cập nhật UI
        }
      } else {
        throw 'Playlist không tồn tại';
      }
    } catch (error) {
      print('Lỗi khi tải danh sách bài hát của Playlist: $error');
      throw error;
    }
  }
}
