import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotepadDialog extends StatefulWidget {
  @override
  _NotepadDialogState createState() => _NotepadDialogState();
}

class _NotepadDialogState extends State<NotepadDialog> {
  List<bool> suspectSelected = [false, false, false, false, false, false];
  List<bool> weaponSelected = [false, false, false, false, false, false];
  List<bool> roomSelected = [false, false, false, false, false, false];
  String caseNotes = "";

  @override
  void initState() {
    super.initState();
    loadPrefs(); // Load preferences when dialog is created
  }

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      suspectSelected = prefs
          .getStringList("suspectSelected")
          ?.map((val) => val == "true")
          .toList() ??
          [false, false, false, false, false, false];
      weaponSelected = prefs
          .getStringList("weaponSelected")
          ?.map((val) => val == "true")
          .toList() ??
          [false, false, false, false, false, false];
      roomSelected = prefs
          .getStringList("roomSelected")
          ?.map((val) => val == "true")
          .toList() ??
          [false, false, false, false, false, false];
      caseNotes = prefs.getString("caseNotes") ?? "";
    });
  }

  Future<void> savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("suspectSelected",
        suspectSelected.map((val) => val.toString()).toList());
    prefs.setStringList(
        "weaponSelected", weaponSelected.map((val) => val.toString()).toList());
    prefs.setStringList(
        "roomSelected", roomSelected.map((val) => val.toString()).toList());
    prefs.setString("caseNotes", caseNotes);
  }

  List<String> suspects = [
    "Mr. Green",
    "Prof. Plum",
    "Col. Mustard",
    "Mrs. Peacock",
    "Miss Scarlet",
    "Mrs. White"
  ];

  List<String> weapons = [
    "Candlestick",
    "Knife",
    "Lead Pipe",
    "Revolver",
    "Rope",
    "Wrench"
  ];

  List<String> rooms = [
    "Kitchen",
    "Library",
    "Hall",
    "Study",
    "Ballroom",
    "Dining Room"
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Notepad'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Suspects',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...List.generate(suspects.length, (index) {
              return CheckboxListTile(
                title: Text(suspects[index]),
                value: suspectSelected[index],
                onChanged: (val) =>
                    setState(() => suspectSelected[index] = val!),
              );
            }),
            Text(
              'Weapons',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...List.generate(weapons.length, (index) {
              return CheckboxListTile(
                title: Text(weapons[index]),
                value: weaponSelected[index],
                onChanged: (val) =>
                    setState(() => weaponSelected[index] = val!),
              );
            }),
            Text(
              'Rooms',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...List.generate(rooms.length, (index) {
              return CheckboxListTile(
                title: Text(rooms[index]),
                value: roomSelected[index],
                onChanged: (val) =>
                    setState(() => roomSelected[index] = val!),
              );
            }),
            TextField(
              decoration: InputDecoration(
                hintText: 'Case Notes',
              ),
              maxLines: null, // This allows for multiline input
              onChanged: (value) =>
                  setState(() => caseNotes = value),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            savePrefs(); // Save data on closing the dialog
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
