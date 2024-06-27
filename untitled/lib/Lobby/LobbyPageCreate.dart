import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/Reusuables/CustomAppBar.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:untitled/Reusuables/global.dart';
import 'package:http/http.dart' as http;

class LobbyPageCreate extends StatefulWidget {
  @override
  _LobbyPageCreateState createState() => _LobbyPageCreateState();
}

class _LobbyPageCreateState extends State<LobbyPageCreate> {
  int selectedIndex = -1;
  int characterIndex = -1;
  TextEditingController codeController = TextEditingController();
  String createdCode = "CODE";

  Future<void> shareApp() async {
    // Set the app link and the message to be shared
    final String message =
        'Come solve a mystery with me! Join Cluedo lobby with Code: $createdCode';

    // Share the app link and message using the share dialog
    await FlutterShare.share(title: 'Share Code', text: message);
  }

  var playersList;

  // Function to periodically update the player list
  void startPeriodicUpdates() {
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (mounted) {
        // Fetch updated player list
        getPlayers();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startPeriodicUpdates();
  }

  void createGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ph = prefs.getString('phone')!;
    prefs.setString("code", createdCode);
    print(ph);
    print(global.url);

    final completeUrl =
        Uri.parse('http://192.168.143.166:8000/' + 'create_lobby/$ph/$characterIndex/');

    final response = await http.post(completeUrl);

    if (response.statusCode == 200) {
      try {
        setState(() {
          createdCode = jsonDecode(response.body)['message'];
          selectedIndex = 0; //
        });

        print(createdCode); // Print the created code for debugging (optional)
      } on FormatException catch (e) {
        // Handle JSON parsing errors
        print('Error parsing JSON response: $e');
      } catch (error) {
        // Handle other potential errors
        print('Error during API call: $error');
      }
    } else {
      // Handle non-200 status codes (replace with specific error handling)
      print(
          'Error: API call failed with status code ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  void getPlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ph = prefs.getString('phone')!;

    final completeUrl = Uri.parse(global.url + 'get_lobby_chars/$createdCode/');

    final response = await http.get(completeUrl);

    if (response.statusCode == 200) {
      try {
        setState(() {
          playersList = jsonDecode(response.body)['players'];
        });

        print(playersList);
      } on FormatException catch (e) {
        print('Error parsing JSON response: $e');
      } catch (error) {
        // Handle other potential errors
        print('Error during API call: $error');
      }
    } else {
      print(
          'Error: API call failed with status code ${response.statusCode} - ${response.reasonPhrase}');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 99,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/backnews.png'),
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter),
        ),
        child: selectedIndex == -1
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Colors.black),
                        bottom: BorderSide(width: 1.0, color: Colors.black),
                      ),
                    ),
                    child: Center(
                      child: Text('Choose Your Character',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width * 0.038,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w800,
                            height: 0,
                          )),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/backnews.png"),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(10)),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio:
                            0.9, // Adjust as needed to control box size
                      ),
                      shrinkWrap: true,
                      itemCount: 6, // Number of characters
                      itemBuilder: (context, index) {

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                                characterIndex = index;
                              });

                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  10), // Make the boxes rounded
                              border: Border.all(
                                  color: characterIndex == index
                                      ? redcol
                                      : Colors.transparent,
                                  width: 5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/$index.png', // Replace with your asset path and format
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Visibility(
                      visible: characterIndex !=
                          -1, // Show only if a character is selected
                      child: ElevatedButton(
                        onPressed: () {
                          print('hey');
                          setState(() {
                            characterIndex = 0;
                          });
                          createGame();
                          getPlayers();
                        },
                        child: Text("start"),
                      )),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to the Cluedo Lobby!',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Text('Game code: $createdCode'),
                      SizedBox(height: 10),
                      // Display player list as a table
                      playersList == null || playersList.isEmpty
                          ? Text('No players joined yet.')
                          : DataTable(
                              columns: [
                                DataColumn(
                                  label: Text('Player'),
                                ),
                                DataColumn(
                                  label: Text('Character'),
                                ),
                              ],
                              rows: [
                                // Show up to 6 rows
                                for (int i = 0; i < 7; i++)
                                  if (i < playersList.length)
                                    DataRow(cells: [
                                      DataCell(Text(
                                          playersList[i][0])), // Player name
                                      DataCell(Text(playersList[i]
                                          [1])), // Chosen character
                                    ])
                                  else
                                    DataRow(cells: [
                                      DataCell(
                                          Text('')), // Empty cell for player
                                      DataCell(
                                          Text('')), // Empty cell for character
                                    ]),
                              ],
                            ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedIndex = 0;
                          });
                          print(selectedIndex);
                        },
                        child: Text('Start Game'),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          shareApp();
                        },
                        child: Icon(Icons.share),
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}
