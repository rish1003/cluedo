import 'dart:math';

import 'package:flutter/material.dart';
import 'package:untitled/Reusuables/custommsg.dart';

class Dice extends StatefulWidget {
  final Function(int) onValueChanged;

  const Dice({Key? key, required this.onValueChanged}) : super(key: key);

  @override
  _DiceState createState() => _DiceState();
}

class _DiceState extends State<Dice> {
  int _diceValue = 1;

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
      onTap: _rollDice,
      child: Image.asset(
        'assets/0.png', // Replace 'assets/dice_$_diceValue.png' with your actual dice images
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

  String currentPlayer = "";
  int _diceValue = 1;
  List<String> roomNames = [
    "Hall",
    "Study",
    "Ballroom",
    "Kitchen",
    "Bedroom",
    'Dining'
  ];
  Map<String, List<int>> characterStartingPoints = {
    'Scarlet': [11, 8],
    'Mustard': [0, 3],
    'White': [4, 11],
    'Green': [0, 7],
    'Peacock': [7, 0],
    'Plum': [11, 4],
  };


  List<String> roomNamesLetter = ["h", "st", "ba", "ki", "be", 'di'];
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
    ['1', 'h', 'h', '0', '0', '0', '0', '0', 'st', 'st', 'st', '1'],
    ['1', 'h', 'h', '0', '0', '0', '0', '0', 'st', 'st', 'st', '1'],
    ['1', 'h', 'h', '0', '0', '0', '0', '0', '0', '0', '0', '1'],
    ['1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1'],
    ['1', '0', '0', '0', '0', '0', '0', 'di', 'di', 'di', '0', '1'],
    ['1', '0', 'ki', 'ki', 'ki', '0', '0', 'di', 'di', 'di', '0', '1'],
    ['1', '0', 'ki', 'ki', 'ki', '0', '0', '0', '0', '0', '0', '1'],
    ['1', '0', '0', '0', '0', '0', '0', '0', '0', 'ba', 'ba', '1'],
    ['1', 'be', 'be', 'be', '0', '0', '0', '0', '0', 'ba', 'ba', '1'],
    ['1', 'be', 'be', 'be', '0', '0', '0', '0', '0', 'ba', 'ba', '1'],
    ['1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'],
  ];

  List<String> characters = [];
  Map<String, List<int>> playerCharacter = {};
  late int currentplayerindex;

  @override
  void initState() {
    super.initState();
    fetchPlayers();
    initializePlayerCharacters();
    switchTurn(); // Start the game by switching the turn
  }

  void fetchPlayers() {
    // Simulating server response
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
        playerCharacter[character] = List.from(characterStartingPoints[character]!);
      }
    }
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

  void movePiece(String character, int row, int column) {
    if (validTurn(character, row, column)) {
      setState(() {
        playerCharacter[character] = [row, column];
        switchTurn();
      });
    }
  }

  bool validTurn(String character, int row, int column) {
    List<int> currentPosition = characterStartingPoints[character]!;
    int horizontalDistance = (row - currentPosition[0]).abs();
    int verticalDistance = (column - currentPosition[1]).abs();
    int totalSteps = horizontalDistance + verticalDistance;
    bool exitRoom =
    cluedoBoard[currentPosition[0]][currentPosition[1]] != '0' &&
        cluedoBoard[currentPosition[0]][currentPosition[1]] != '1'
        ? true
        : false;
    bool enterRoom =
    cluedoBoard[row][column] != '0' && cluedoBoard[row][column] != '1'
        ? true
        : false;
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

  Future<void> switchTurn() async {
    // Check if it's the current user's turn
    final bool isUserTurn = await checkUserTurn();

    // If it's the user's turn, switch the turn and inform the server
    if (isUserTurn) {
      setState(() {
        List<String> keys = playerCharacter.keys.toList();
        int nextIndex = (currentplayerindex + 1) % keys.length;
        currentPlayer = keys[nextIndex];
      });

      // Inform the server about the turn switch
      informServerAboutTurnSwitch();

    } else {
      CustomMessage.toast("Not your turn");
    }
  }

  Future<bool> checkUserTurn() async {
    // API call to check if it's the current user's turn
    // For demonstration purposes, always return true
    return true;
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
    return path;
  }
  void informServerAboutTurnSwitch() {
    // API call to inform the server about the turn switch
  }

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final boardWidth = screenWidth * 0.9;
    final boardHeight = screenHeight * 0.8;
    return Scaffold(
      appBar: AppBar(title: Text('Cluedo Game')),
      body: Stack(
        children: [
          // Game board
          Center(
            child: Container(
              width: screenWidth * 0.95,
              height: screenHeight * 0.5,
              child: Column(
                children: [
                  // Dice
                  Text('Dice Value: $_diceValue'),
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
                ],
              ),
            ),
          ),
        ],
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
        movePiece(currentPlayer, j, i);
      },
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: _getColor(tileType),
          border: Border.all(color: Colors.black),
        ),
        child: Stack(
          children: pieceWidgets,
        ),
      ),
    );
  }

  Color _getColor(String k) {
    switch (k) {
      case 'h':
        return Colors.brown;
      case 'st':
        return Colors.blue;
      case 'li':
        return Colors.green;
      case 'ki':
        return Colors.orange;
      case 'di':
        return Colors.red;
      case 'du':
        return Colors.purple;
      case 'be':
        return Colors.pink;
      case 'ba':
        return Colors.yellow;
      case '1':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }
}
