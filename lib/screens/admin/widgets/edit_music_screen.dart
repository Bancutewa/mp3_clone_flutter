import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mp3_clone/models/music.dart';
import 'package:mp3_clone/providers/music_provider.dart';

class EditMusicScreen extends StatefulWidget {
  static const routeName = '/edit-music';

  final Music music; // Dữ liệu bài nhạc cần chỉnh sửa

  const EditMusicScreen({Key? key, required this.music}) : super(key: key);

  @override
  _EditMusicScreenState createState() => _EditMusicScreenState();
}

class _EditMusicScreenState extends State<EditMusicScreen> {
  final _titleController = TextEditingController();
  final _artistsController = TextEditingController();
  final _durationController = TextEditingController();
  final _lyricsController = TextEditingController();

  bool _isLoading = false;
  html.File? _audioFile;
  html.File? _imageFile;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị mặc định cho các trường
    _titleController.text = widget.music.title;
    _artistsController.text = widget.music.artists;
    _durationController.text = widget.music.duration.toString();
    _lyricsController.text = widget.music.lyrics!;
  }

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

  Future<void> _updateMusic() async {
    if (_titleController.text.isEmpty ||
        _artistsController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _lyricsController.text.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? audioDownloadUrl = widget.music.audioUrl;
      String? imageDownloadUrl = widget.music.imageUrl;

      if (_audioFile != null) {
        // Tải lên file âm thanh mới nếu có
        final audioFileName = _audioFile!.name;
        final audioUploadTask = FirebaseStorage.instance
            .ref('audioFiles/$audioFileName')
            .putBlob(_audioFile!);
        audioDownloadUrl = await (await audioUploadTask).ref.getDownloadURL();
      }

      if (_imageFile != null) {
        // Tải lên hình ảnh mới nếu có
        final imageFileName = _imageFile!.name;
        final imageUploadTask = FirebaseStorage.instance
            .ref('imageFiles/$imageFileName')
            .putBlob(_imageFile!);
        imageDownloadUrl = await (await imageUploadTask).ref.getDownloadURL();
      }

      final updatedMusic = widget.music.copyWith(
        title: _titleController.text,
        artists: _artistsController.text,
        duration: int.parse(_durationController.text),
        lyrics: _lyricsController.text,
        imageUrl: imageDownloadUrl ?? widget.music.imageUrl,
        audioUrl: audioDownloadUrl ?? widget.music.audioUrl,
      );

      await MusicProvider.instance.updateMusic(updatedMusic);

      _showSnackBar('Chỉnh sửa bài nhạc thành công!');
      Navigator.of(context).pop();
    } catch (error) {
      _showSnackBar('Có lỗi xảy ra, vui lòng thử lại.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hiển thị SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh Sửa Bài Nhạc'),
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
              TextFormField(
                controller: _lyricsController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Lời bài hát',
                  hintText: 'Nhập lời bài hát ở đây...',
                ),
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
                onPressed: _isLoading ? null : _updateMusic,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Cập Nhật Bài Nhạc'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
