import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
    );
  }
}