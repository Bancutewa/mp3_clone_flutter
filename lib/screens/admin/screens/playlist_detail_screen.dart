import 'package:flutter/material.dart';
import 'package:mp3_clone/models/playlist.dart';
import 'package:mp3_clone/providers/playlist_provider.dart';
import 'package:mp3_clone/screens/admin/screens/music_selection_screen.dart';
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

      // Sau khi thêm bài hát, tải lại danh sách bài hát
      await _loadMusicList();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bài hát đã được thêm vào Playlist!')),
      );
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

      // Sau khi xóa bài hát, tải lại danh sách bài hát
      await _loadMusicList();

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

  Future<void> _navigateToMusicSelection() async {
    final selectedMusicId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (ctx) => MusicSelectionScreen(),
      ),
    );

    if (selectedMusicId != null) {
      _addMusicToPlaylist(selectedMusicId);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMusicList(); // Lấy danh sách bài hát khi màn hình được tạo
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final playlist = playlistProvider.getById(widget.playlist.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.title),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Hiển thị ảnh đại diện Playlist
                  if (playlist.imageUrl != null)
                    Image.network(playlist.imageUrl!)
                  else
                    Icon(Icons.playlist_play, size: 100),

                  SizedBox(height: 20),

                  // Nút thêm bài hát
                  ElevatedButton.icon(
                    onPressed: _navigateToMusicSelection,
                    icon: Icon(Icons.add),
                    label: Text('Thêm Bài Hát'),
                  ),
                  SizedBox(height: 20),

                  // Danh sách bài hát
                  playlist.musicList != null && playlist.musicList!.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: playlist.musicList!.length,
                            itemBuilder: (ctx, index) {
                              final music = playlist.musicList![index];
                              return ListTile(
                                leading: music.imageUrl.isNotEmpty
                                    ? Image.network(music.imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover)
                                    : Icon(Icons.music_note),
                                title: Text(music.title),
                                subtitle: Text(music.artists),
                                trailing: IconButton(
                                  icon: Icon(Icons.remove_circle),
                                  onPressed: () =>
                                      _removeMusicFromPlaylist(music.id),
                                ),
                              );
                            },
                          ),
                        )
                      : const Text('Playlist này chưa có bài hát nào.'),
                ],
              ),
            ),
    );
  }
}
