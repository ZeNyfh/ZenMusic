import 'package:flutter/material.dart';

import 'Pages/NowPlayingPage.dart';
import 'Pages/PlayerPage.dart';
import 'Pages/QueuePage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(home: const HomeScreen());
    }
}

class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    int _selectedIndex = 0;

    final List<Widget> _pages = [
        YouTubePlayer(),
        NowPlayingPage(),
        QueuePage(),
    ];

    void _onItemTapped(int index) {
        setState(() => _selectedIndex = index);
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('ZenMusic')),
            body: _pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.play_arrow),
                        label: 'Now Playing',
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.queue_music),
                        label: 'Queue',
                    ),
                ],
            ),
        );
    }
}
