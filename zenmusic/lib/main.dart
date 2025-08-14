import 'package:flutter/material.dart';
import 'package:zenmusic/ui/NPPage.dart';
import 'package:zenmusic/ui/SearchPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SearchPage(), // Start with SearchPage
    );
  }
}