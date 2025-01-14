import 'package:flutter/material.dart';
import 'package:mp3_clone/models/music.dart';
import 'package:mp3_clone/models/playlist.dart';
import 'package:mp3_clone/providers/music_provider.dart';
import 'package:mp3_clone/providers/playing_log_provider.dart';
import 'package:mp3_clone/providers/playlist_provider.dart';
import 'package:mp3_clone/providers/ranked_music_provider.dart';
import 'package:mp3_clone/screens/admin/admin_screen.dart';
import 'package:mp3_clone/screens/admin/screens/music_management_screen.dart';
import 'package:mp3_clone/screens/admin/screens/music_selection_screen.dart';
import 'package:mp3_clone/screens/admin/screens/playlist_management_screen.dart';
import 'package:mp3_clone/screens/admin/widgets/add_music_screen.dart';
import 'package:mp3_clone/screens/admin/widgets/add_playlist_screen.dart';
import 'package:mp3_clone/screens/admin/widgets/edit_music_screen.dart';
import 'package:mp3_clone/screens/admin/widgets/edit_playlist_screen.dart';
import 'package:provider/provider.dart';

import 'screens/explorer/all_playlists_screen.dart';
import 'providers/recent_search_provider.dart';
import './screens/common/account_screen.dart';
import './screens/auth/forgot_screen.dart';
import './screens/auth/login_screen.dart';
import './screens/auth/signup_screen.dart';
import './screens/common/playing_screen.dart';
import './screens/common/playlist_screen.dart';
import './screens/common/search_screen.dart';
import './screens/common/welcome_screen.dart';
import 'utils/config.dart';
import 'screens/common/home_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MusicProvider.instance.fetchAndSetData();
  await PlaylistProvider.instance.fetchAndSetPlaylists();
  await PlayingLogProvider.instance.fetchAndSetData();
  await RankedMusicProvider.instance.countAndSort();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              MusicProvider.instance
        ), // Đảm bảo provider này có mặt
        ChangeNotifierProvider(
          create: (_) => PlaylistProvider.instance, // Thêm PlaylistProvider vào đây
        ),
        // Các provider khác nếu có
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> loadPreferences() async {
      if (FirebaseAuth.instance.currentUser != null) {
        await Config.instance.loadAccountData();
      }
      await RecentSearchProvider.instance.load();
    }

    return FutureBuilder(
        future: loadPreferences(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator());
          }
          return MaterialApp(
              title: 'Zing MP3',
              theme: ThemeData(
                primaryColor: const Color(0xFF814C9E),
                hintColor: const Color(0xFF797979),
                fontFamily: 'Open Sans',
              ),
              debugShowCheckedModeBanner: false,
              initialRoute: Config.instance.myAccount == null
                  ? WelcomeScreen.routeName
                  : HomeScreen.routeName,
              routes: {
                WelcomeScreen.routeName: (ctx) => const WelcomeScreen(),
                LoginScreen.routeName: (ctx) => const LoginScreen(),
                SignUpScreen.routeName: (ctx) => const SignUpScreen(),
                ForgotScreen.routeName: (ctx) => const ForgotScreen(),
                HomeScreen.routeName: (ctx) => const HomeScreen(),
                AccountScreen.routeName: (ctx) => const AccountScreen(),
                SearchScreen.routeName: (ctx) => const SearchScreen(),
                PlayingScreen.routeName: (ctx) => const PlayingScreen(),
                PlaylistScreen.routeName: (ctx) => const PlaylistScreen(),
                AllPlaylistsScreen.routeName: (ctx) =>
                    const AllPlaylistsScreen(),
                AdminScreen.routeName: (ctx) => const AdminScreen(),
                AddMusicScreen.routeName: (ctx) => const AddMusicScreen(),
                MusicManagementScreen.routeName: (ctx) =>
                    const MusicManagementScreen(),
                EditMusicScreen.routeName: (ctx) {
                  final music = ModalRoute.of(ctx)!.settings.arguments as Music;
                  return EditMusicScreen(music: music);
                },
                PlaylistManagementScreen.routeName: (ctx) => const PlaylistManagementScreen(),
                AddPlaylistScreen.routeName: (ctx) => AddPlaylistScreen(),
                EditPlaylistScreen.routeName: (ctx) {
                  final playlist = ModalRoute.of(ctx)!.settings.arguments as Playlist;
                  return EditPlaylistScreen(playlist: playlist);
                },
                MusicSelectionScreen.routeName: (ctx) => MusicSelectionScreen(),
              });
        });
  }
}
