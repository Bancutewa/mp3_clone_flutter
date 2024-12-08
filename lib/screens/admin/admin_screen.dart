import 'package:flutter/material.dart';
import 'package:mp3_clone/screens/admin/widgets/add_music_screen.dart';
import '../common/welcome_screen.dart'; // Đừng quên import màn hình AddMusicScreen

class AdminScreen extends StatelessWidget {
  static const routeName = '/admin';

  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _card(String title, String assetIcon, VoidCallback onPressed) {
      final side = MediaQuery.of(context).size.width / 2.5;

      return SizedBox(
        width: side,
        height: side,
        child: Card(
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Flexible(
                  flex: 4,
                  child: Center(
                      child: Image.asset(
                    assetIcon,
                    fit: BoxFit.cover,
                  ))),
              Flexible(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextButton(
                      onPressed:
                          onPressed, // Khi nhấn vào card, sẽ gọi onPressed
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Quản trị viên'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    WelcomeScreen.routeName, (Route<dynamic> route) => false);
              },
              icon: const Icon(Icons.logout_rounded)),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Card để quản lý bài nhạc
              _card('Quản lý danh sách bài nhạc',
                  'assets/icons/musical_notes_96.png', () {
                // Khi nhấn vào card "Quản lý danh sách bài nhạc", mở màn hình quản lý bài nhạc
              }),

              // Card để thêm bài nhạc
              _card('Thêm Bài Nhạc', 'assets/icons/add_music_96.png', () {
                // Khi nhấn vào card "Thêm Bài Nhạc", chuyển tới màn hình thêm bài nhạc
                Navigator.of(context).pushNamed(AddMusicScreen.routeName);
              }),

              _card('Quản lý danh sách playlist',
                  'assets/icons/playlist_2_96.png', () {
                // Khi nhấn vào card "Quản lý danh sách playlist", mở màn hình quản lý playlist
              }),
              _card('Gửi thông báo', 'assets/icons/email_send_96.png', () {
                // Khi nhấn vào card "Gửi thông báo", mở màn hình gửi thông báo
              }),
            ],
          ),
        ),
      ),
    );
  }
}
