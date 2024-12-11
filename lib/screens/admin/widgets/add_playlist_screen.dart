import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mp3_clone/models/playlist.dart';
import 'package:mp3_clone/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class AddPlaylistScreen extends StatefulWidget {
  static const routeName = '/add-playlist';

  @override
  _AddPlaylistScreenState createState() => _AddPlaylistScreenState();
}

class _AddPlaylistScreenState extends State<AddPlaylistScreen> {
  final _titleController = TextEditingController();
  html.File? _imageFile;
  bool _isUploading = false;
  bool _isAddingMusic = false;

  // Chọn ảnh từ thư viện
  Future<void> _pickImageFile() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = 'image/*';
    input.click();

    input.onChange.listen((e) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        setState(() {
          _imageFile = files[0];
        });
      }
    });
  }

  // Tải lên ảnh lên Firebase Storage
  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    try {
      final imageFileName = _imageFile!.name;
      final imageUploadTask = FirebaseStorage.instance
          .ref('playlistImages/$imageFileName')
          .putBlob(_imageFile!);
      final imageDownloadUrl =
          await (await imageUploadTask).ref.getDownloadURL();
      return imageDownloadUrl;
    } catch (error) {
      print('Lỗi tải ảnh lên: $error');
      return null;
    }
  }

  // Hàm lưu Playlist
  Future<void> _savePlaylist() async {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin!');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? imageUrl = await _uploadImage();

    final newPlaylist = Playlist(
      id: Playlist.generateId(),
      title: _titleController.text,
      imageUrl: imageUrl,
      musicIDs: [], // Khởi tạo một danh sách rỗng cho musicIDs
    );

    try {
      await Provider.of<PlaylistProvider>(context, listen: false)
          .addPlaylist(newPlaylist);
      _showSnackBar('Thêm Playlist thành công!');
      Navigator.of(context).pop();
    } catch (error) {
      _showSnackBar('Đã xảy ra lỗi khi thêm Playlist.');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Thêm bài hát vào Playlist
  Future<void> _addMusicToPlaylist(String musicId) async {
    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);

    final playlist = playlistProvider.playlists.last; // Chọn playlist vừa tạo

    setState(() {
      _isAddingMusic = true;
    });

    try {
      await playlistProvider.addMusicToPlaylist(playlist.id, musicId);
      _showSnackBar('Bài hát đã được thêm vào Playlist!');
    } catch (error) {
      _showSnackBar('Đã xảy ra lỗi khi thêm bài hát.');
    } finally {
      setState(() {
        _isAddingMusic = false;
      });
    }
  }

  // Phương thức riêng để hiển thị SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Playlist'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.cancel),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tên Playlist'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _pickImageFile,
                    child: const Text('Chọn Ảnh'),
                  ),
                ],
              ),
              _imageFile == null
                  ? const SizedBox.shrink()
                  : Text('File Hình Ảnh: ${_imageFile!.name}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isUploading ? null : _savePlaylist,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('Lưu Playlist'),
              ),
              const SizedBox(height: 20),
              // Thêm bài hát vào playlist
              ElevatedButton(
                onPressed: _isAddingMusic
                    ? null
                    : () async {
                        String musicId = 'music_example_id'; // Thay đổi musicId thực tế
                        await _addMusicToPlaylist(musicId);
                      },
                child: _isAddingMusic
                    ? const CircularProgressIndicator()
                    : const Text('Thêm Bài Hát vào Playlist'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
