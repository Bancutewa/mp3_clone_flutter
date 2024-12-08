import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mp3_clone/models/music.dart';
import 'package:mp3_clone/providers/music_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMusicScreen extends StatefulWidget {
  static const routeName = '/add-music';

  const AddMusicScreen({Key? key}) : super(key: key);

  @override
  _AddMusicScreenState createState() => _AddMusicScreenState();
}

class _AddMusicScreenState extends State<AddMusicScreen> {
  final _titleController = TextEditingController();
  final _artistsController = TextEditingController();
  final _durationController = TextEditingController();

  html.File? _audioFile;
  html.File? _imageFile;

  bool _isLoading = false;

  Future<void> _pickAudioFile() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = 'audio/*';
    input.click();

    input.onChange.listen((e) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        setState(() {
          _audioFile = files[0];
        });
      }
    });
  }

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

  Future<void> _uploadMusic() async {
    // Kiểm tra các trường nhập
    if (_titleController.text.isEmpty ||
        _artistsController.text.isEmpty ||
        _audioFile == null ||
        _imageFile == null ||
        _durationController.text.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Tải lên file âm thanh
      final audioFileName = _audioFile!.name;
      final audioUploadTask = FirebaseStorage.instance
          .ref('audioFiles/$audioFileName')
          .putBlob(_audioFile!);
      final audioDownloadUrl =
          await (await audioUploadTask).ref.getDownloadURL();

      // Tải lên hình ảnh
      final imageFileName = _imageFile!.name;
      final imageUploadTask = FirebaseStorage.instance
          .ref('imageFiles/$imageFileName')
          .putBlob(_imageFile!);
      final imageDownloadUrl =
          await (await imageUploadTask).ref.getDownloadURL();

      // Tạo đối tượng nhạc mới
      final newMusic = Music(
        id: '',
        title: _titleController.text,
        artists: _artistsController.text,
        imageUrl: imageDownloadUrl,
        thumbnailUrl: imageDownloadUrl,
        audioUrl: audioDownloadUrl,
        duration: int.parse(_durationController.text),
      );

      // Thêm nhạc
      await MusicProvider.instance.addMusic(newMusic);

      _showSnackBar('Thêm bài nhạc thành công!');
      Navigator.of(context).pop();
    } catch (error) {
      _showSnackBar('Có lỗi xảy ra, vui lòng thử lại.');
    } finally {
      setState(() {
        _isLoading = false;
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
        title: const Text('Thêm Bài Nhạc'),
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
                decoration: const InputDecoration(labelText: 'Tên Bài Hát'),
              ),
              TextField(
                controller: _artistsController,
                decoration: const InputDecoration(labelText: 'Nghệ Sĩ'),
              ),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Thời gian (giây)'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _pickAudioFile,
                    child: const Text('Chọn Âm Thanh'),
                  ),
                  ElevatedButton(
                    onPressed: _pickImageFile,
                    child: const Text('Chọn Ảnh'),
                  ),
                ],
              ),
              _audioFile == null
                  ? const SizedBox.shrink()
                  : Text('File Âm Thanh: ${_audioFile!.name}'),
              _imageFile == null
                  ? const SizedBox.shrink()
                  : Text('File Hình Ảnh: ${_imageFile!.name}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _uploadMusic,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Lưu Bài Nhạc'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
