import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:untitled/Reusuables/global.dart';
import 'package:video_player/video_player.dart';

import '../Lobby/LobbyPage.dart';
import '../Lobby/LobbyPageCreate.dart';
import 'Cards.dart';

class AndroidLarge2 extends StatefulWidget {
  @override
  State<AndroidLarge2> createState() => _AndroidLarge2State();
}

class _AndroidLarge2State extends State<AndroidLarge2> {
  bool isPressed = false;
  String getCurrentDate() {
    var now = DateTime.now();
    var formatter = DateFormat('EEEE, dd MMM yyyy');
    return formatter.format(now);
  }

  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/newsvid.mp4');

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            width: screenWidth,
            height: screenHeight - 99,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      'assets/backnews.png'), // Replace with your image URL
                  fit: BoxFit.cover,
                  alignment: Alignment
                      .bottomCenter // Adjust the fit as per your requirement
                  ),
            ),
            child: Column(
              children: [
                Container(
                  width: screenWidth,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1.0, color: Colors.black),
                      bottom: BorderSide(width: 1.0, color: Colors.black),
                    ),
                  ),
                  child: Center(
                    child: Text(getCurrentDate(),
                        style: GoogleFonts.newsCycle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          height: 0,
                        )),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 0),
                  width: screenWidth,
                  height: screenHeight * 0.47,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: SizedBox(
                          width: screenWidth * 1.011,
                          height: screenHeight * 0.097,
                          child: Text(
                            'MURDER AT THE TUDOR MANSION',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.068,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w800,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.09,
                        child: Container(
                          width: screenWidth *
                              0.43, // Adjust this value based on your design
                          child: Text(
                            "In a shocking turn of events,the picturesque Tudor Mansion, renowned for hosting the most elaborate dinner parties, has become the epicenter of a real-life murder mystery straight out a horror film. \n\nThe victim, identified as Mr. Reginald Blackwood, was found lifeless in the mansion's opulent study, sending shockwaves through the exclusive community\n\nThe Tudor Mansion, known for its lavish décor and secret passageways, now houses a crime scene that has captivated the imagination of amateur sleuths and mystery enthusiasts alike. The game is afoot, and the mansion's array of suspects and rooms only intensify the intrigue.",
                            textAlign: TextAlign.justify,
                            style: GoogleFonts.raleway(
                              color: Colors.black,
                              fontSize: screenWidth * 0.023,
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 45,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                            }});
                          },
                          child: Container(
                            height: screenHeight * 0.37,
                            width: screenWidth * 0.43,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Text('hey'),
                                VideoPlayer(_controller),
                              ],
                            ),
                            color: redcol,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1, color: Colors.black),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/newsphoto2.png'),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('A most peculiar set of',
                              style: GoogleFonts.raleway(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 2,
                              )),
                          InkWell(
                            onTap: () {
                              print("SUSPECTS");
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return MyDialog(
                                    imagePaths: [
                                      'assets/sus/sc.png',
                                      'assets/sus/mu.png',
                                      'assets/sus/pe.png',
                                      'assets/sus/wh.png',
                                      'assets/sus/pl.png',
                                      'assets/sus/gr.png',
                                      // Add more image paths as needed
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              'SUSPECTS',
                              style: GoogleFonts.raleway(
                                color: redcol,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                height: 0,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              print("WEAPONS");
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return MyDialog(
                                    imagePaths: [
                                      'assets/w/7.png',
                                      'assets/w/8.png',
                                      'assets/w/9.png',
                                      'assets/w/10.png',
                                      'assets/w/11.png',
                                      'assets/w/12.png',
                                      // Add more image paths as needed
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              'WEAPONS',
                              style: GoogleFonts.raleway(
                                color: purplecol,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                height: 0,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              print("ROOMS");
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return MyDialog(
                                    imagePaths: [
                                      'assets/r/13.png',
                                      'assets/r/14.png',
                                      'assets/r/15.png',
                                      'assets/r/16.png',
                                      'assets/r/17.png',
                                      'assets/r/18.png',
                                      // Add more image paths as needed
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              'ROOMS',
                              style: GoogleFonts.raleway(
                                color: bluecol,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                height: 0,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              print("RULES");
                            },
                            child: Text(
                              "Follow the rules,",
                              style: GoogleFonts.raleway(
                                color: yellowcol,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                height: 2,
                              ),
                            ),
                          ),
                          Text(
                            "and find the murderer",
                            style: GoogleFonts.raleway(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog();
                      },
                    );
                  },
                  onTapDown: (details) {
                    setState(() {
                      isPressed = true;
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      isPressed = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isPressed ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'SOLVE THE MYSTERY',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPressed ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDialog extends StatefulWidget {
  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.25,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/join.png'), fit: BoxFit.fill),
            shape: BoxShape.rectangle,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Your background image goes here
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LobbyPage(source: "joinGame")),
                  );
                },
                child: Image.asset("assets/joingame.png"),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LobbyPageCreate()),
                  );
                },
                child: Image.asset("assets/creategame.png"),
              )
            ],
          ),
        ),
      ],
    );
  }
}
