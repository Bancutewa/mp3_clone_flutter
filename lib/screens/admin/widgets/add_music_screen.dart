import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mp3_clone/models/music.dart';
import 'package:mp3_clone/providers/music_provider.dart';
import 'package:path/path.dart';
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
  final _audioUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();
  final _durationController = TextEditingController();
  File? _audioFile;
  File? _imageFile;

  bool _isLoading = false;

  // Chọn file âm thanh
  Future<void> _pickAudioFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _audioFile = File(pickedFile.path);
      });
    }
  }

  // Chọn file hình ảnh
  Future<void> _pickImageFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadMusic() async {
    if (_titleController.text.isEmpty ||
        _artistsController.text.isEmpty ||
        _audioFile == null ||
        _imageFile == null ||
        _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
        content: Text('Vui lòng điền đầy đủ thông tin!'),
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Tải lên file âm thanh lên Firebase Storage
      final audioFileName = basename(_audioFile!.path);
      final audioUploadTask = FirebaseStorage.instance
          .ref('audioFiles/$audioFileName')
          .putFile(_audioFile!);
      final audioDownloadUrl =
          await (await audioUploadTask).ref.getDownloadURL();

      // Tải lên hình ảnh lên Firebase Storage
      final imageFileName = basename(_imageFile!.path);
      final imageUploadTask = FirebaseStorage.instance
          .ref('imageFiles/$imageFileName')
          .putFile(_imageFile!);
      final imageDownloadUrl =
          await (await imageUploadTask).ref.getDownloadURL();

      // Lưu dữ liệu vào Firestore
      final newMusic = Music(
        id: '',
        title: _titleController.text,
        artists: _artistsController.text,
        imageUrl: imageDownloadUrl,
        thumbnailUrl: imageDownloadUrl,
        audioUrl: audioDownloadUrl,
        duration: int.parse(_durationController.text),
      );

      // Gọi phương thức addMusic của provider
      await MusicProvider.instance.addMusic(newMusic);

      ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
        content: Text('Thêm bài nhạc thành công!'),
      ));

      Navigator.of(context as BuildContext).pop();
    } catch (error) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
        content: Text('Có lỗi xảy ra, vui lòng thử lại.'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Bài Nhạc'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
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
                  : Text('File Âm Thanh: ${_audioFile!.path}'),
              _imageFile == null
                  ? const SizedBox.shrink()
                  : Text('File Hình Ảnh: ${_imageFile!.path}'),
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
