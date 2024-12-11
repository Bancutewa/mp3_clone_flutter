import 'package:flutter/material.dart';
import 'package:mp3_clone/screens/admin/screens/playlist_detail_screen.dart';
import 'package:mp3_clone/screens/admin/widgets/add_playlist_screen.dart';
import 'package:mp3_clone/screens/admin/widgets/edit_playlist_screen.dart';
import 'package:mp3_clone/screens/common/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:mp3_clone/providers/playlist_provider.dart';

class PlaylistManagementScreen extends StatelessWidget {
  static const routeName = '/playlist-management';

  const PlaylistManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý Playlist'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName); // Quay lại trang Home
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Nút thêm playlist
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AddPlaylistScreen.routeName);
              },
              icon: Icon(Icons.add),
              label: Text('Thêm Playlist'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.purple, shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 20), // Khoảng cách giữa nút và danh sách playlist
            Consumer<PlaylistProvider>(
              builder: (ctx, playlistProvider, _) {
                final playlists = playlistProvider.playlists;

                // Kiểm tra nếu playlists chưa được tải hoặc có lỗi trong việc tải
                if (playlists.isEmpty) {
                  return Center(child: Text('Chưa có playlist nào, hãy thêm playlist mới!'));
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: playlists.length,
                    itemBuilder: (ctx, index) {
                      final playlist = playlists[index];

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: playlist.imageUrl != null
                                ? NetworkImage(playlist.imageUrl!)
                                : AssetImage('assets/images/account/avatar.png') as ImageProvider,
                          ),
                          title: Text(playlist.title),
                          subtitle: Text('Số bài hát: ${playlist.musicIDs.length.toString()}'),
                          onTap: () {
                            // Chuyển hướng đến PlaylistDetailScreen khi bấm vào Playlist
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => PlaylistDetailScreen(playlist: playlist),
                              ),
                            );
                          },
                          trailing: PopupMenuButton(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => EditPlaylistScreen(
                                      playlist: playlist,
                                    ),
                                  ),
                                );
                              } else if (value == 'delete') {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Xóa Playlist'),
                                    content: Text('Bạn có chắc chắn muốn xóa playlist này không?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop(false);
                                        },
                                        child: Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop(true);
                                        },
                                        child: Text('Xóa'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await playlistProvider.deletePlaylist(playlist.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Playlist đã được xóa.'),
                                    ),
                                  );
                                }
                              }
                            },
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Chỉnh sửa'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Xóa'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
