import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/Reusuables/global.dart';
import 'dart:convert';
import '../Main Page/Cards.dart';

class PlayerCardStackDialog extends StatefulWidget {

  @override
  _PlayerCardStackDialogState createState() => _PlayerCardStackDialogState();
}

class _PlayerCardStackDialogState extends State<PlayerCardStackDialog> {
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _getPlayerCardStack();
  }

  Future<void> _getPlayerCardStack() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String playerId = prefs.getString('phone')!;
    final response = await http.get(
      Uri.parse(global.url+'get_playerstack/'+playerId+'/'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> cardStackData = responseData['card_stack'];

      setState(() {
        _imagePaths = cardStackData
            .map<String>((cardData) => _getCardImagePath(cardData))
            .toList();
      });
    } else {
      // Handle error
      print('Failed to fetch card stack: ${response.statusCode}');
    }
  }

  String _getCardImagePath(Map<String, dynamic> cardData) {
    String cardType = cardData['card_type'];
    String cardId = cardData['card_id'].toString();
    return 'assets/$cardType/$cardId.png';
  }

  @override
  Widget build(BuildContext context) {
    return MyDialog(imagePaths: _imagePaths);
  }
}