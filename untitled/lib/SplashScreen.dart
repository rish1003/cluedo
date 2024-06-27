import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/Game/MainGame.dart';
import 'package:untitled/Reusuables/global.dart';


import 'HomePage.dart';
import 'Login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool showLogo = true;
  bool showContainer = false;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      setState(() {
        showLogo = false;
      });
    });
    Timer(Duration(seconds: 2), () {
      setState(() {
        showContainer = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/bg.jpg'), // Replace with your image asset path
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Logo with AnimatedPositioned
            AnimatedPositioned(
              duration: Duration(seconds: 1),
              curve: Curves.easeInOut,
              top: showLogo ? 0.45 * screenHeight : 0.25 * screenHeight,
              left: 0.12 * screenWidth,
              child: Image.asset('assets/cluelog.png'),
            ),

            // Container with AnimatedOpacity and Positioned
            Positioned(
              top: 0.45 * screenHeight, // Adjust positioning as needed
              left: 0.30 * screenWidth,
              child: AnimatedOpacity(
                  duration: Duration(seconds: 1),
                  opacity: showContainer ? 1.0 : 0.0,
                  child: MyButton()),
            ),

            // Buttons with AnimatedOpacity (implement them below)
          ],
        ),
      ),
    );
  }
}

class MyButton extends StatefulWidget {
  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  List<Color> defaultColors = [yellowcol, browncol];
  List<Color> pressedColors = [redcol, browncol];

  late List<Color> currentColors;

  @override
  void initState() {
    super.initState();
    currentColors = defaultColors;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('phone','')!;

        String ph = prefs.getString('phone')!;

        if (ph == '') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
        else{
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );

        }
      },

    onTapDown: (details) {
        setState(() {
          currentColors = pressedColors;
        });
      },
      onTapCancel: () {
        setState(() {
          currentColors = defaultColors;
        });
      },
      onTapUp: (details) {
        setState(() {
          currentColors = defaultColors;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: currentColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: currentColors.last,
              offset: Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          'Start Game',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
