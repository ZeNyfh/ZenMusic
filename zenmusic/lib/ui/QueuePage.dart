import 'package:flutter/material.dart';

import 'objects/CustomNavBar.dart';


class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      bottomNavigationBar: CustomNavBar(currentIndex: 0, context: context),
    );
  }
}
