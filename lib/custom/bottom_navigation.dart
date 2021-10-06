import 'package:flutter/material.dart';
import 'package:project_gmastereki/custom/new_color.dart';
import 'package:project_gmastereki/menu/notes.dart';
import 'package:project_gmastereki/menu/schedules.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);
  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

final myTheme = NewColor();

class _BottomNavigationState extends State<BottomNavigation> {

  int _currentIndex = 0;

  void onTappedBar(int index){
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children =
    [
      const Notes(),
      const Schedule(),
    ];

    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTappedBar,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: myTheme.colors[color1],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sticky_note_2_sharp),
            label: 'Notes',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}
