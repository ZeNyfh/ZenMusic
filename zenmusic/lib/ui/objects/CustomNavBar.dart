import 'package:flutter/material.dart';

import '../../services/NavService.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: "Now Playing"),
        BottomNavigationBarItem(icon: Icon(Icons.queue_music), label: "Queue"),
      ],
      onTap: (index) => changePage(index, context), // Make sure changePage is accessible
      backgroundColor: Color(0xffffffff),
      currentIndex: currentIndex,
      elevation: 8,
      iconSize: 18,
      selectedItemColor: Color(0xff3a57e8),
      unselectedItemColor: Color(0xff505050),
      selectedFontSize: 14,
      unselectedFontSize: 12,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }
}