import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/Register.dart';
import 'package:untitled/Reusuables/custommsg.dart';
import 'package:untitled/Reusuables/global.dart';
import 'package:http/http.dart' as http;
import 'HomePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  List<Color> defaultColors = [yellowcol, browncol];
  List<Color> pressedColors = [redcol, browncol];

  late List<Color> currentColors;

  @override
  void initState() {
    super.initState();
    currentColors = defaultColors;
  }
  TextEditingController pwcontroller = new TextEditingController() ;
  TextEditingController usercontroller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    var currentColors = [redcol, yellowcol];
    return Scaffold(
      appBar: AppBar(

        centerTitle: true,
        title: Text('Login',style: GoogleFonts.volkhov(
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
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 24.0),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: usercontroller,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: pwcontroller,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                InkWell(
                  onTap: () async {
                    var request = http.MultipartRequest('POST', Uri.parse(global.url+'/login/'+usercontroller.text+'/'+pwcontroller.text+'/'));
                    http.StreamedResponse response = await request.send();

                    if (response.statusCode == 200) {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString('phone', usercontroller.text);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    }
                    else {
                      CustomMessage.toast("Invalid Credentials");
                    }


                  },
                  onTapDown: (details) {
                    setState(() {
                      currentColors = pressedColors;
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
                      'Login',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                TextButton(
                  onPressed: () => {
                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage1()),
                  )
                  }, // Add your forgot password action here
                  child: Text('New? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
