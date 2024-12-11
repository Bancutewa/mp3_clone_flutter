import 'package:flutter/material.dart';
import 'package:mp3_clone/models/music.dart';
import 'package:mp3_clone/providers/music_provider.dart';
import 'package:provider/provider.dart';

class MusicSelectionScreen extends StatelessWidget {
  static const routeName = '/music-selection';

  @override
  Widget build(BuildContext context) {
    // Gọi fetchAndSetData để tải dữ liệu trước
    Provider.of<MusicProvider>(context, listen: false).fetchAndSetData();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn Bài Hát'),
      ),
      body: FutureBuilder<List<Music>>(
        future: Provider.of<MusicProvider>(context, listen: false).getAllMusic(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Không có bài hát nào.'),
            );
          }

          final musicList = snapshot.data!;

          return ListView.builder(
            itemCount: musicList.length,
            itemBuilder: (ctx, index) {
              final music = musicList[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: music.imageUrl != null
                      ? Image.network(
                          music.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.music_note),
                  title: Text(music.title),
                  subtitle: Text(music.artists),  // Thay id bằng artists
                  onTap: () {
                    Navigator.of(context).pop(music.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
