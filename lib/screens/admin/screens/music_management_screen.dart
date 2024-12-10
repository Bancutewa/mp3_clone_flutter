import 'package:flutter/material.dart';
import 'package:mp3_clone/providers/music_provider.dart';
import 'package:mp3_clone/screens/admin/widgets/add_music_screen.dart';
import 'package:mp3_clone/screens/admin/widgets/edit_music_screen.dart';
import 'package:provider/provider.dart'; // Đảm bảo import provider

class MusicManagementScreen extends StatelessWidget {
  static const routeName = '/music-management';

  const MusicManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý bài nhạc'),
        // Thêm nút quay lại trong AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Quay lại màn hình trước đó
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AddMusicScreen.routeName);
              },
              child: const Text('Thêm Bài Nhạc'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<MusicProvider>(
                // Sử dụng Consumer để lắng nghe thay đổi dữ liệu
                builder: (ctx, musicProvider, _) {
                  return ListView.builder(
                    itemCount: musicProvider.list.length,
                    itemBuilder: (ctx, index) {
                      final music = musicProvider.list[index];
                      return ListTile(
                        title: Text(music.title),
                        subtitle: Text(music.artists),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Nút Sửa
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  EditMusicScreen.routeName,
                                  arguments: music,
                                );
                              },
                            ),
                            // Nút Xoá
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // Xác nhận xoá bài nhạc
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Xoá Bài Nhạc'),
                                    content: const Text(
                                        'Bạn có chắc chắn muốn xoá bài nhạc này?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx)
                                              .pop(); // Đóng dialog
                                        },
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          musicProvider.deleteMusic(music.id);
                                          Navigator.of(ctx)
                                              .pop(); // Đóng dialog
                                        },
                                        child: const Text('Xoá'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
