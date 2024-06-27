import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../HomePage.dart';
import '../Reusuables/custommsg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:untitled/Reusuables/global.dart';

class RoomDialog extends StatefulWidget {
  final String roomletter;

  const RoomDialog({
    Key? key,
    required this.roomletter,
  }) : super(key: key);

  @override
  State<RoomDialog> createState() => _RoomDialogState();
}

class _RoomDialogState extends State<RoomDialog> {
  void makeSuggestion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedCharacter = characters[0]; // Default selected character
        String selectedWeapon = weapons[0]; // Default selected weapon

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Make a Suggestion"),
              content: Container(
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Select Character:"),
                      DropdownButton<String>(
                        value: selectedCharacter,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCharacter = newValue!;
                          });
                        },
                        items: characters.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 10),
                      Text("Select Weapon:"),
                      DropdownButton<String>(
                        value: selectedWeapon,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedWeapon = newValue!;
                          });
                        },
                        items: weapons.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    CustomMessage.toast("Rishika has $selectedCharacter");
                    print("Suggested $selectedCharacter with $selectedWeapon");
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Suggest'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  List<String> characters = [
    'Scarlet',
    'Mustard',
    'White',
    'Green',
    'Peacock',
    'Plum',
  ];

  List<String> weapons = [
    'Knife',
    'Candlestick',
    'Revolver',
    'Rope',
    'Lead Pipe',
    'Wrench',
  ];
  Map<String, int> suspectsmap = {
    'Scarlet': 1,
    'Mustard': 3,
    'White': 2,
    'Green': 5,
    'Peacock': 6,
    'Plum': 2,
  };

  // Weapons mapped to their numbers
  Map<String, int> weaponsmap = {
    'Knife': 8,
    'Candlestick': 7,
    'Revolver': 10,
    'Rope': 11,
    'Lead Pipe': 9,
    'Wrench': 12,
  };

  // Rooms mapped to their numbers
  Map<String, int> roomsmap  = {
    'Hall': 18,
    'Library': 17,
    'Study': 16,
    'Dining': 15,
    'Ballroom': 14,
    'Conservatory': 13,
  };


  void makeAccusation() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedCharacter = characters[0]; // Default selected character
        String selectedWeapon = weapons[0]; // Default selected weapon
        String selectedRoom = roomNames[0]; // Default selected room

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Make an Accusation"),
              content: Container(
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Select Character:"),
                      DropdownButton<String>(
                        value: selectedCharacter,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCharacter = newValue!;
                          });
                        },
                        items: characters.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 10),
                      Text("Select Weapon:"),
                      DropdownButton<String>(
                        value: selectedWeapon,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedWeapon = newValue!;
                          });
                        },
                        items: weapons.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 10),
                      Text("Select Room:"),
                      DropdownButton<String>(
                        value: selectedRoom,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRoom = newValue!;
                          });
                        },
                        items: roomNames.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    int characterNumber = suspectsmap[selectedCharacter]!;
                    int weaponNumber = weaponsmap[selectedWeapon]!;
                    int roomNumber = roomsmap[selectedRoom]!;
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String code = prefs.getString('code')!;
                    final response = await http.post(
                      Uri.parse(global.url+"answer/"+code+"/"+characterNumber.toString()+"/"+weaponNumber.toString()+"/"+roomNumber.toString()+"/"),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(<String, dynamic>{
                        'codes': 'your_lobby_code',
                        'suspect_card_id': characterNumber,
                        'weapon_card_id': weaponNumber,
                        'room_card_id': roomNumber,
                      }),
                    );

                    if (response.statusCode == 200) {
                      // If the accusation is correct
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Congratulations!"),
                            content: Text("Correct guess! You win!"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => HomePage()),
                                  ); // Close the accusation dialog
                                  // Navigate to the homepage or wherever you want
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // If the accusation is incorrect
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Better luck next time!"),
                            content: Text("Incorrect guess!"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('Accuse'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<String> roomNames = [
    "Hall",
    "Study",
    "Ballroom",
    "Kitchen",
    "Library",
    'Conservatory'
  ];


  @override
  Widget build(BuildContext context) {
    var roomname = widget.roomletter;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: 600,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/$roomname.gif'), // Replace with your background GIF
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
               makeSuggestion(); // Execute the suggestion action
              },
              child: Text('Make a Suggestion'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                makeAccusation(); // Execute the accusation action
              },
              child: Text('Make an Accusation'),
            ),
          ],
        ),
      ),
    );
  }
}


