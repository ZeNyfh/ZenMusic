import 'package:flutter/material.dart';

import '../ui/NPPage.dart';
import '../ui/QueuePage.dart';
import '../ui/SearchPage.dart';

void changePage(int index, BuildContext context) {
  switch (index) {
    case 0:
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPage())
      );
    case 1:
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NPPage())
      );
    case 2:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QueuePage())
      );
  }
}