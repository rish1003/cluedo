import 'package:flutter/material.dart';


class CluedoBoardtry extends StatefulWidget {
  @override
  _CluedoBoardtryState createState() => _CluedoBoardtryState();
}

class _CluedoBoardtryState extends State<CluedoBoardtry> {
  // Define the grid size
  final int rows = 3;
  final int columns = 3;

  // Define start points for movable pieces
  final List<Offset> startPoints = [
    Offset(0, 0), // Example starting point at top-left corner
    // Add more starting points as needed
  ];

  // Store the current position of each movable piece
  List<Offset> currentPositions = [];

  @override
  void initState() {
    super.initState();
    currentPositions.addAll(startPoints);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          rows,
              (row) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              columns,
                  (column) {
                final index = row * columns + column;
                return Draggable(
                  child: CluedoPiece(),
                  feedback: CluedoPiece(),
                  childWhenDragging: Container(),
                  onDragEnd: (details) {
                    setState(() {
                      // Update the current position of the dragged piece
                      currentPositions[index] = details.offset;
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CluedoPiece extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
    );
  }
}
