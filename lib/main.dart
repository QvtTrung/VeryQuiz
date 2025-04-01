import 'package:audio_session/audio_session.dart';
import 'package:ct484_project/screens/auth_screen.dart';
import 'package:ct484_project/services/audio_service.dart';
import 'package:ct484_project/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'services/question_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ct484_project/providers/auth_manager.dart';

import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/levels_screen.dart';
import 'screens/game_screen.dart';
import 'screens/achievements_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = await AudioSession.instance;
  await session.configure(AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playback,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
    avAudioSessionMode: AVAudioSessionMode.defaultMode,
    androidAudioAttributes: const AndroidAudioAttributes(
      contentType: AndroidAudioContentType.music,
      usage: AndroidAudioUsage.media,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    androidWillPauseWhenDucked: false,
  ));

  QuestionService();
  await dotenv.load(fileName: ".env");
  await AudioService().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _loadTheme(); // Đọc trạng thái dark mode khi khởi động
  }

  Future<void> _loadTheme() async {
    bool isDarkMode = await _themeService.isDarkMode();
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  void changeThemeMode(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
    });
    _themeService.setDarkMode(isDarkMode); // Lưu trạng thái
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthManager(),
        ),
      ],
      child: MaterialApp(
        title: 'Trivia Game',
        debugShowCheckedModeBanner: false,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlue,
            brightness: Brightness.dark,
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (context) =>
                    HomeScreen(changeThemeMode: changeThemeMode),
              );
            case LevelScreen.routeName:
              return MaterialPageRoute(
                builder: (context) => const LevelScreen(),
              );
            case SettingsScreen.routeName:
              return MaterialPageRoute(
                builder: (context) =>
                    SettingsScreen(changeThemeMode: changeThemeMode),
              );
            case GameScreen.routeName:
              final category = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => GameScreen(category: category),
              );
            case AchievementsScreen.routeName:
              return MaterialPageRoute(
                builder: (context) => const AchievementsScreen(),
              );
            case '/auth':
              return MaterialPageRoute(
                builder: (context) => AuthScreen(),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(
                    child: Text("Route not found!"),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
