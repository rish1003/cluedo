import 'package:firebase_core/firebase_core.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/Game/MainGame.dart';
import 'package:untitled/Login.dart';
import 'package:untitled/Reusuables/global.dart';
import 'package:untitled/SplashScreen.dart';
import 'firebase_options.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 await SharedPreferences.getInstance();
 SharedPreferences prefs = await SharedPreferences.getInstance();
 prefs.setString('phone', '');
  await prefs.clear();

 await Flame.device;
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cluedo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: browncol),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
