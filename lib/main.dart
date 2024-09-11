import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_poc/controller/controller_provider.dart';
import 'package:video_poc/views/reels/reels.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ControllerProvider>(
            create: (_) => ControllerProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter POC REELS',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const VideoListView(),
      ),
    );
  }
}
