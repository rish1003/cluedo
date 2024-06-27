import 'package:flutter/material.dart';
import 'package:untitled/Reusuables/global.dart';

class MyDialog extends StatefulWidget {
  final List<String> imagePaths;

  MyDialog({required this.imagePaths});

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.525,
            width: MediaQuery.of(context).size.width ,
            color: Colors.transparent,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.imagePaths.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(widget.imagePaths[index]),
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            left: -10,
            bottom: 0,
            child: _currentPage == 0
                ? SizedBox() // Hide left arrow on the first card
                : GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0 && _currentPage > 0) {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.transparent,
                      ),
                      onPressed: () {
                        if (_currentPage > 0) {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
          ),
          Positioned(
            top: 0,
            right: -10,
            bottom: 0,
            child: _currentPage == widget.imagePaths.length - 1
                ? SizedBox() // Hide right arrow on the last card
                : GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! < 0 &&
                          _currentPage < widget.imagePaths.length - 1) {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.transparent,
                      ),
                      onPressed: () {
                        if (_currentPage < widget.imagePaths.length - 1) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
