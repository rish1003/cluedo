import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/Reusuables/custommsg.dart';
import 'HomePage.dart';
import 'Reusuables/global.dart';

class RegisterPage1 extends StatefulWidget {
  @override
  _RegisterPage1State createState() => _RegisterPage1State();
}

class _RegisterPage1State extends State<RegisterPage1> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        centerTitle: true,
        title: Text('Register',style: GoogleFonts.volkhov(
          color: redcol,
          fontSize: 33,
          fontWeight: FontWeight.w400,

        ),),
        flexibleSpace: Stack(
            children: [
              Image.asset(
                'assets/bg.jpg', // Replace with your actual background image path
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ]
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/bg.jpg'), // Replace with your image asset path
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(20),

        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Welcome!',
                  style: TextStyle(fontSize: 24.0),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  validator: _validatePhoneNumber,
                ),
                SizedBox(height: 5.0),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  validator: _validateName,
                ),
                SizedBox(height: 5.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                SizedBox(height: 5.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Re-Enter Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  validator: _validateConfirmPassword,
                ),
                SizedBox(height: 10.0),
                TextButton(
                  onPressed: _validateInputs,
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter phone number');
      return null;
    }
    if (value.length != 10 || int.tryParse(value) == null) {
      Fluttertoast.showToast(msg: 'Please enter a valid 10-digit phone number');
      return null;
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your name');
      return null;
    }
    if (!value.contains(RegExp(r'^[a-zA-Z]+$'))) {
      Fluttertoast.showToast(msg: 'Name should contain only alphabets');
      return null;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter password');
      return null;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      Fluttertoast.showToast(msg: 'Please re-enter password');
      return null;
    }
    if (value != _passwordController.text) {
      Fluttertoast.showToast(msg: 'Passwords do not match');
      return null;
    }
    return null;
  }

  Future<void> _validateInputs() async {
    if (_phoneNumberController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'All fields are required');
      return;
    }

    if (_validatePhoneNumber(_phoneNumberController.text) == null &&
        _validateName(_nameController.text) == null &&
        _validatePassword(_passwordController.text) == null &&
        _validateConfirmPassword(_confirmPasswordController.text) == null) {
      var request = http.MultipartRequest('POST', Uri.parse(global.url+'/register/'));
      request.fields.addAll({
        'number': _phoneNumberController.text,
        'password': _passwordController.text,
        'name': _nameController.text
      });


      http.StreamedResponse response = await request.send();
      print(response.statusCode);
      if (response.statusCode == 201) {

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('phone', _phoneNumberController.text);
        prefs.setString('name', _nameController.text);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
    }
    else {
        if (response.statusCode != 200){await utf8.decodeStream(response.stream).then((value) {
            Map<String, dynamic> responseBody = json.decode(value);

            // Iterate over the keys in the response body
            responseBody.keys.forEach((key) {
              // Extract the error message associated with each key and display it using SnackBar
              String errorMessage = responseBody[key][0];
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  duration: Duration(seconds: 2), // Adjust as needed
                ),
              );
            });
          });}


        }
      }

    // All inputs are valid, proceed with registration
      // Your registration logic here
    }
  }

