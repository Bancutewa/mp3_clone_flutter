import 'package:flutter/material.dart';
import 'package:mp3_clone/models/playlist.dart';
import 'package:mp3_clone/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class PlaylistDetailScreen extends StatefulWidget {
  static const routeName = '/playlist-detail';

  final Playlist playlist;

  PlaylistDetailScreen({required this.playlist});

  @override
  _PlaylistDetailScreenState createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  bool _isLoading = false;

  // Lấy danh sách bài hát từ database và cập nhật Playlist
  Future<void> _loadMusicList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<PlaylistProvider>(context, listen: false)
          .loadMusicForPlaylist(widget.playlist.id);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi tải danh sách bài hát.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Xử lý thêm bài hát vào Playlist
  Future<void> _addMusicToPlaylist(String musicId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<PlaylistProvider>(context, listen: false)
          .addMusicToPlaylist(widget.playlist.id, musicId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bài hát đã được thêm vào Playlist!')),
      );
      _loadMusicList(); // Tải lại danh sách bài hát sau khi thêm
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi thêm bài hát.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Xử lý xóa bài hát khỏi Playlist
  Future<void> _removeMusicFromPlaylist(String musicId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<PlaylistProvider>(context, listen: false)
          .removeMusicFromPlaylist(widget.playlist.id, musicId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bài hát đã được xóa khỏi Playlist!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi xóa bài hát.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMusicList(); // Lấy danh sách bài hát khi màn hình được tạo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.title),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.cancel),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Ảnh đại diện Playlist
                    widget.playlist.imageUrl != null
                        ? Image.network(widget.playlist.imageUrl!)
                        : const SizedBox.shrink(),

                    const SizedBox(height: 20),

                    // Nút thêm bài hát
                    ElevatedButton.icon(
                      onPressed: () async {
                        final String? newMusicId = await showDialog<String>(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: Text('Chọn Bài Hát'),
                              content: TextField(
                                decoration: InputDecoration(hintText: 'Nhập ID bài hát'),
                                onChanged: (value) {
                                  // Lưu ID bài hát tạm thời nếu cần
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop(null);
                                  },
                                  child: Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Trả về ID bài hát đã nhập
                                    Navigator.of(ctx).pop('music123'); // Thay bằng ID thực tế
                                  },
                                  child: Text('Thêm'),
                                ),
                              ],
                            );
                          },
                        );

                        if (newMusicId != null) {
                          _addMusicToPlaylist(newMusicId);
                        }
                      },
                      icon: Icon(Icons.add),
                      label: Text('Thêm Bài Hát'),
                    ),

                    const SizedBox(height: 20),

                    // Hiển thị danh sách bài hát
                    widget.playlist.musicIDs.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.playlist.musicIDs.length,
                            itemBuilder: (ctx, index) {
                              final musicId = widget.playlist.musicIDs[index];
                              return ListTile(
                                title: Text('Bài hát $musicId'),
                                trailing: IconButton(
                                  icon: Icon(Icons.remove_circle),
                                  onPressed: () => _removeMusicFromPlaylist(musicId),
                                ),
                              );
                            },
                          )
                        : const Text('Playlist này chưa có bài hát nào.'),
                  ],
                ),
              ),
            ),
    );
  }
}
