import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/Game/notepad.dart';
import 'package:untitled/Game/playercard.dart';
import 'package:untitled/Game/suggestiondiialog.dart';
import 'package:untitled/Reusuables/CustomAppBar.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/Reusuables/global.dart';
import '../Reusuables/custommsg.dart';
import 'chat.dart';

class Dice extends StatefulWidget {
  final Function(int) onValueChanged;

  const Dice({Key? key, required this.onValueChanged}) : super(key: key);

  @override
  _DiceState createState() => _DiceState();
}

class _DiceState extends State<Dice> {
  int _diceValue = 6;
  Future<bool> checkUserTurn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = prefs.getString('code')!;
    String ph = prefs.getString('phone')!;

    var request = http.Request(
        'GET', Uri.parse(global.url + '/checkturn/' + code! + '/' + ph! + "/"));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      final isTrue = jsonResponse['is_turn'] ??
          false; // Extract value of "is_true" field, default to false
      return isTrue; // Return true if "is_true" is true, false otherwise
    } else {
      print(response.reasonPhrase);
      return false; // Return false if request fails
    }
  }


  void _rollDice() {
    final newValue = Random().nextInt(6) + 1;
    setState(() {
      _diceValue = newValue;
    });
    widget.onValueChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await checkUserTurn()){
          _rollDice();
        }
        else{
          CustomMessage.toast("Not your turn!");
        }

      }
      ,
      child: Image.asset(
        'assets/dice_$_diceValue.png',
        width: 50,
        height: 50,
        fit: BoxFit.contain,
      ),
    );
  }
}

class CluedoPiece extends StatelessWidget {
  final Color color;
  final String character;

  const CluedoPiece({Key? key, required this.color, required this.character})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          character[0],
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class Game2 extends StatefulWidget {
  @override
  State<Game2> createState() => _Game2State();
}

class _Game2State extends State<Game2> {
  var code;
  var ph;

  @override
  void initState() {
    super.initState();
    fetchPlayers();
    getcodephone();
    initializePlayerCharacters();
  }
  List<Map<String, String>> players = [
    {'user1': 'assets/1.png'},
    {'user2': 'assets/1.png'},
    {'user3': 'assets/1.png'},
    // Add more players as needed
  ];
  Future<void> getcodephone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ph = prefs.getString("phone");
      code = 'pvzkz';//prefs.getString('code');
    });
  }

  String currentPlayer = '';
  int _diceValue = 1;
  List<String> roomNames = [
    "Hall",
    "Study",
    "Ballroom",
    "Library",
    "Conservatory",
    'Dining'
  ];
  List<String> roomNamesLetter = ["h", "st", "ba", "li", "co", 'di'];
  Map<String, List<List<int>>> roomDoors = {
    'Hall': [
      [0, 5],
      [11, 5]
    ],
    'Study': [
      [1, 0]
    ],
    'Ballroom': [
      [1, 5],
      [4, 0],
      [6, 0]
    ],
    'Kitchen': [
      [1, 11]
    ],
    'Conservatory': [
      [4, 11]
    ],
    'Bedroom': [
      [9, 0],
      [11, 5]
    ],
    'Dining': [
      [9, 11]
    ],
  };

  List<List<String>> cluedoBoard = [
    ['1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'],
    ['1', 'h', 'h', '0', '0', '0', '0', '0', 'di', 'di', 'di', '1'],
    ['1', 'h', 'h', '0', '0', '0', '0', '0', 'di', 'di', 'di', '1'],
    ['1', 'h', 'h', '0', '0', '0', '0', '0', '0', '0', '0', '1'],
    ['1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1'],
    ['1', '0', '0', '0', '0', '0', '0', 'ba', 'ba', 'ba', '0', '1'],
    ['1', '0', 'co', 'co', 'co', '0', '0', 'ba', 'ba', 'ba', '0', '1'],
    ['1', '0', 'co', 'co', 'co', '0', '0', '0', '0', '0', '0', '1'],
    ['1', '0', '0', '0', '0', '0', '0', '0', '0', 'li', 'li', '1'],
    ['1', 'st', 'st', 'st', '0', '0', '0', '0', '0', 'li', 'li', '1'],
    ['1', 'st', 'st', 'st', '0', '0', '0', '0', '0', 'li', 'li', '1'],
    ['1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'],
  ];

  Map<String, List<int>> characterStartingPoints = {
    'Scarlet': [11, 8],
    'Mustard': [0, 3],
    'White': [4, 11],
    'Green': [0, 7],
    'Peacock': [7, 0],
    'Plum': [11, 4],
  };
  void enterRoom(String roomName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RoomDialog(
          roomletter: roomName
        );
      },
    );
  }
  Color _getCharacterColor(String character) {
    switch (character) {
      case 'Scarlet':
        return Colors.red;
      case 'Mustard':
        return Colors.yellow;
      case 'White':
        return Colors.white;
      case 'Green':
        return Colors.green;
      case 'Peacock':
        return Colors.blue;
      case 'Plum':
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  bool validTurn(String character, int row, int column) {
    List<int> currentPosition = playerCharacter[character]!;
    int horizontalDistance = (row - currentPosition[0]).abs();
    int verticalDistance = (column - currentPosition[1]).abs();
    int totalSteps = horizontalDistance + verticalDistance;

    if (totalSteps == _diceValue) {
      if (cluedoBoard[row][column] == '0') {
        return true;
      } else if (cluedoBoard[row][column] == '1') {
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  void movePiece(String character, int row, int column) async {
    generatePath(playerCharacter[character]![0], playerCharacter[character]![1], row, column);
    bool isUserTurn = await checkUserTurn();
    generatePath(playerCharacter[character]![0], playerCharacter[character]![1], row, column);
    if (validTurn(character, row, column) && isUserTurn) {
      setState(() {
        playerCharacter[character] = [row, column];
        switchTurn();
      });
      CustomMessage.toast("Piece moved successfully");
      if (cluedoBoard[row][column] != '0' && cluedoBoard[row][column] != '1') {
        // Open the room dialog
        enterRoom(roomNamesLetter[roomNames.indexOf(cluedoBoard[row][column])]);
      }

    } else {
      CustomMessage.toast("Invalid move or not your turn");
    }
  }


  List<String> characters = [];
  Map<String, List<int>> playerCharacter = {};
  late int currentplayerindex;


  void fetchPlayers() async {


  final serverResponse = ["1:Scarlet", "2:Mustard", "3:White"];
    final extractedCharacters = serverResponse
        .map((entry) => entry.split(":")[1])
        .toList(); // Extract character names
    setState(() {
      characters = extractedCharacters;
      currentPlayer = characters[0];
      currentplayerindex = 0;
    });
  }

  void initializePlayerCharacters() {
    // Initialize player character positions based on characterStartingPoints
    for (var character in characters) {
      if (characterStartingPoints.containsKey(character)) {
        playerCharacter[character] =
            List.from(characterStartingPoints[character]!);
      }
    }
  }

  Future<void> switchTurn() async {
    final bool isUserTurn = await checkUserTurn();

    // If it's the user's turn, switch the turn and inform the server
    if (isUserTurn) {
      var request = http.Request(
          'POST', Uri.parse(global.url + '/changeturn/' + code + '/'));
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }

      setState(() {
        List<String> keys = playerCharacter.keys.toList();
        int nextIndex = (currentplayerindex + 1) % keys.length;
        currentplayerindex = nextIndex;
        currentPlayer = keys[nextIndex];
      });


    } else {
      CustomMessage.toast("Not your turn");
    }
  }

  Future<bool> checkUserTurn() async {

    var request = http.Request(
        'GET', Uri.parse(global.url + '/checkturn/' + code! + '/' + ph! + "/"));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      final isTrue = jsonResponse['is_turn'] ??
          false; // Extract value of "is_true" field, default to false
      return isTrue; // Return true if "is_true" is true, false otherwise
    } else {
      print(response.reasonPhrase);
      return false; // Return false if request fails
    }
  }

  List<List<int>> generatePath(
      int startRow, int startCol, int endRow, int endCol) {
    List<List<int>> path = [];
    int rowIncrement = endRow > startRow ? 1 : (endRow < startRow ? -1 : 0);
    int colIncrement = endCol > startCol ? 1 : (endCol < startCol ? -1 : 0);
    int currentRow = startRow;
    int currentCol = startCol;
    path.add([currentRow, currentCol]);
    while (currentRow != endRow || currentCol != endCol) {
      currentRow += rowIncrement;
      currentCol += colIncrement;
      path.add([currentRow, currentCol]);
    }
    print(path);
    return path;
  }
  void updateDiceValue(int newValue) {
    print(_diceValue);
    setState(() {
      _diceValue = newValue;
    });
  }


  Future<void> informServerAboutTurnSwitch() async {}
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final numberOfPlayers = players.length;
    final playersTop = numberOfPlayers ~/ 2; // Players on the top
    final playersBottom = numberOfPlayers - playersTop; // Players on the bottom
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.50,
          height: 100,
          child: Image.asset('assets/logoclue.png'),
        ),
        centerTitle: true, // Center the title
        flexibleSpace: Stack(
            children: [
              Image.asset(
                'assets/backnews.png', // Replace with your actual background image path
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ]
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              // Navigate to the chat screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(lobbyId: 'pvzkz',phnum: ph,),
                ),
              );
            },
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/backnews.png'),
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter),
        ),

        padding: EdgeInsets.all(10),
        width: screenWidth,
        height: screenHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top row of player avatars
              Center(
                child: SizedBox(
                  height: 100, // Adjust the height as needed
                  child: Center(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: playersTop,
                      itemBuilder: (context, index) {
                        final player = players[index];
                        final userName = player.keys.first;
                        final userImage = player.values.first;
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, // Center the children vertically
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: currentplayerindex == index ? Colors.green : null, // Set green border for the current player

                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundImage: AssetImage(userImage),

                                ),
                              ),
                              SizedBox(height: 5),
                              Text(userName),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

              ),
              // Board widget (replace with your board widget)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/board.png"),
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 12,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                      childAspectRatio: 1,
                    ),
                    shrinkWrap: true,
                    itemCount: 144,
                    itemBuilder: (context, index) {
                      var i = index % 12;
                      var j = (index / 12).floor();
                      String k = cluedoBoard[j][i].toString();
                      return buildTileContainer(k, i, j);
                    },
                  ),
                ),
              ),

              // Bottom row of player avatars
              SizedBox(
                height: 100, // Adjust the height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: playersBottom,
                  itemBuilder: (context, index) {
                    final player = players[index + playersTop];
                    final userName = player.keys.first;
                    final userImage = player.values.first;
                    final bottomIndex = index + playersTop;
                    return Container(

                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: currentplayerindex == bottomIndex ? Colors.green : null, // Set green border for the current player

                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: AssetImage(userImage),

                            ),
                          ),
                          SizedBox(height: 5),
                          Text(userName),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 50, // Adjust width as needed
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return PlayerCardStackDialog();

                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: redcol, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20), // Rounded top-left corner
                            bottomRight: Radius.circular(20), // Rounded bottom-left corner
                          ),
                        ),
                      ),
                      child: Icon(Icons.receipt,color: yellowcol,),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Dice(onValueChanged: updateDiceValue),
                  ),
                  SizedBox(
                    width: 50, // Adjust width as needed
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NotepadDialog();
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: redcol, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20), // Rounded top-right corner
                            bottomLeft: Radius.circular(20), // Rounded bottom-right corner
                          ),
                        ),
                      ),
                      child: Icon(Icons.note_alt_sharp,color: yellowcol,),
                    ),
                  ),
                ],
              )

            ]
        ),
      ),
    );
  }

  Widget buildTileContainer(String tileType, int i, int j) {
    bool isRoom = roomNamesLetter.contains(tileType);
    List<Widget> pieceWidgets = [];
    for (String character in playerCharacter.keys) {
      List<int> position = playerCharacter[character]!;
      if (position[0] == j && position[1] == i) {
        pieceWidgets.add(
          GestureDetector(
            onTap: () {
              movePiece(character, j, i);
            },
            child: CluedoPiece(
              color: _getCharacterColor(character),
              character: character,
            ),
          ),
        );
      }
    }
    return GestureDetector(
      onTap: () {
        print(tileType);
        movePiece(currentPlayer, j, i);
      },
      child: Container(
        width: 20,
        height: 20,

        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
                color:
                    Colors.black)), // Set the background color as transparent
        child: Stack(
          children: pieceWidgets,
        ),
      ),
    );
  }




  bool isNextToDoor(int row, int column) {
    // Iterate over all rooms and their doors
    for (var doors in roomDoors.values) {
      // Iterate over doors in the current room
      for (var door in doors) {
        // Check if the tile is adjacent to the current door
        if ((door[0] == row &&
                (door[1] == column - 1 ||
                    door[1] == column + 1)) || // Check left and right
            (door[1] == column && (door[0] == row - 1 || door[0] == row + 1))) {
          // Check top and bottom
          return true; // Tile is next to a door
        }
      }
    }
    return false; // Tile is not next to any door
  }




}
