import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/Game/MainGame.dart';
import 'package:untitled/Reusuables/Components.dart';
import 'package:untitled/Reusuables/CustomAppBar.dart';
import 'package:untitled/Reusuables/global.dart';
import 'package:flutter_share/flutter_share.dart';

import '../Reusuables/custommsg.dart';

class LobbyPage extends StatefulWidget {
  final String source;

  LobbyPage({required this.source});

  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  int selectedIndex = -1;
  int characterIndex = -1;
  TextEditingController codeController = TextEditingController();
  String createdCode = "";
  bool isLoading = true;
  String chosenChar ="";
  Timer? gameTimer;
  Timer? charTimer;
  var playersList;
  void startPeriodicUpdates() {
    charTimer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
      if (mounted) {
        // Fetch updated player list
        getPlayers();
      }
    });
  }
  void gameStatusUpdates(){
    print("her");
    gameTimer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
      if (mounted){
        checkGameStatus();
      }

    });
  }

  void stopPeriodicUpdates() {
    gameTimer?.cancel();
    charTimer?.cancel();
  }

  @override
  void dispose() {
    stopPeriodicUpdates();

    super.dispose();
  }
  Future<void> checkGameStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ph = prefs.getString('phone')!;
    final completeUrl = Uri.parse(global.url + 'status/'+createdCode+"/");
    final response = await http.get(completeUrl);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      String gameStatus = data['game_status'];
      print(gameStatus);
      if (gameStatus == 'started') {

        String lobbyCode = data['lobby_code'];
        // Navigate to the game screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Game2())
        );
      }
    } else {
      print('Error: API call failed with status code ${response.statusCode} - ${response.reasonPhrase}');
    }
  }
  @override
  void initState() {
    super.initState();
    startPeriodicUpdates();
    gameStatusUpdates();
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

  Future<void> shareApp() async {
    final String message =
        'Come solve a mystery with me! Join Cluedo lobby with Code: $createdCode';
    await FlutterShare.share(title: 'Share Code', text: message);
  }

  void joinGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ph = prefs.getString('phone')!;
    prefs.setString("code", createdCode);

    var request = http.Request(
        'POST',
        Uri.parse(
            global.url + '/join_lobby/' + ph + "/" + createdCode + '/' + chosenChar+'/'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  var charactersList;
  Future<void> getChosenCharacters() async {
    print('heyinapi');
    try {
      print(codeController.text);
      var code = codeController.text;
      final completeUrl = Uri.parse(global.url + 'get_chars/$code/');
      final response = await http.get(completeUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          charactersList = List<String>.from(data['characters']);
          isLoading = false;
        });
        print(charactersList);
      } else {
        print(
            'Error: API call failed with status code ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error during API call: $error');
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
              image: AssetImage(
                  'assets/backnews.png'), // Replace with your image URL
              fit: BoxFit.cover,
              alignment: Alignment
                  .bottomCenter // Adjust the fit as per your requirement
              ),
        ),
        child: selectedIndex == -1
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to the Cluedo Lobby!',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Text('Enter the game code:'),
                      SizedBox(height: 10),
                      FormTextField(
                          fieldcontroller: codeController,
                          keytype: TextInputType.text,
                          hinttext: "Enter Code",
                          hinttextcol: redcol,
                          bordercol: redcol,
                          obscure: false)
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            print('hey');
                            getChosenCharacters();
                            createdCode = codeController.text;
                            selectedIndex = 0;
                          });
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
              )
            : selectedIndex == 0
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
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.038,
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
                        child: isLoading
                            ? Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: redcol,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              )
                            : GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio:
                                      0.9, // Adjust as needed to control box size
                                ),
                                shrinkWrap: true,
                                itemCount: 6, // Number of characters
                                itemBuilder: (context, index) {
                                  bool isCharacterAlreadyChosen =
                                      charactersList.contains(index.toString());
                                  return GestureDetector(
                                    onTap: () {
                                      if (isCharacterAlreadyChosen) {
                                        print("Already chosen");
                                        CustomMessage.toast(
                                            "Character already chosen.");
                                      } else {
                                        setState(() {
                                          characterIndex = index;
                                        });
                                      }
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
                                setState(() {
                                  print("start");
                                  chosenChar = characterIndex.toString();
                                  selectedIndex = 1;

                                  joinGame();

                                });
                              },
                              child: Text("Start Game"),)),
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
                                          DataCell(Text(playersList[i]
                                              [0])), // Player name
                                          DataCell(Text(playersList[i]
                                              [1])), // Chosen character
                                        ])
                                      else
                                        DataRow(cells: [
                                          DataCell(Text(
                                              '')), // Empty cell for player
                                          DataCell(Text(
                                              '')), // Empty cell for character
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
