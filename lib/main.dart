import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morphmaze/splash_screen.dart';
import 'app_theme.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MorphMazeApp());
}

class MorphMazeApp extends StatelessWidget {
  const MorphMazeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MorphMaze',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}