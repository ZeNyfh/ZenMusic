import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenMusic',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HelloWorldScreen(),
    );
  }
}

class HelloWorldScreen extends StatefulWidget {
  const HelloWorldScreen({super.key});

  @override
  State<HelloWorldScreen> createState() => _HelloWorldScreenState();
}

class _HelloWorldScreenState extends State<HelloWorldScreen> {
  static const platform = MethodChannel('com.zenyfh.zenmusic/hello');
  String _message = 'Waiting for message...';

  Future<void> _getJavaMessage() async {
    try {
      final String result = await platform.invokeMethod('getMessage');
      setState(() => _message = result);
    } on PlatformException catch (e) {
      setState(() => _message = "Failed: '${e.message}'");
    }
  }

  @override
  void initState() {
    super.initState();
    _getJavaMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZenMusic')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getJavaMessage,
              child: const Text('Call Java Again'),
            ),
          ],
        ),
      ),
    );
  }
}