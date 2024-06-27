import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/Reusuables/CustomAppBar.dart';

import 'Main Page/Story Page.dart';
import 'Reusuables/global.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(),
        body: AndroidLarge2(),
        drawer: Drawer(
          backgroundColor: browncol,

          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/bg.jpg'), // Replace with your image
                    fit: BoxFit.cover,
                  ),
                ),
                accountName: Text('johndoe123', style:  GoogleFonts.raleway(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  height: 0,)),
                accountEmail: Text('+91 9980653944',style:  GoogleFonts.raleway(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 0,)),
                currentAccountPicture:  Icon(Icons.person_2) // Replace with your avatar image
              ),
              ListTile(
                leading: Icon(Icons.edit),
                iconColor: Colors.black,

                title: Text('Edit User',style: GoogleFonts.raleway(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 0,)),
                onTap: () {
                  // Open edit user screen
                },
              ),

              ListTile(
                leading: Icon(Icons.settings),
                iconColor: Colors.black,

                title: Text('Settings',style: GoogleFonts.raleway(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 0,)),
                onTap: () {
                  // Open edit user screen
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                iconColor: Colors.black,

                title: Text('Log Out',style: GoogleFonts.raleway(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 0,)),
                onTap: () {
                  // Open edit user screen
                },
              ),
            ],
          ),
        ));
  }
}

