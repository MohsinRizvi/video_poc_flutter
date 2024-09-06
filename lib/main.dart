import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_poc/controller/controller_provider.dart';
import 'package:video_poc/views/reels/full_view.dart';
import 'package:video_poc/service/network.dart';
import 'package:video_poc/views/reels/reels.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        home:  HLSVideoPlayer(videoUrl: 'https://flipfit-cdn.akamaized.net/flip_hls/661f570aab9d840019942b80-473e0b/video_h1.m3u8',),
      ),
    );
  }
}




class HLSVideoPlayer extends StatefulWidget {
  final String videoUrl;

  HLSVideoPlayer({required this.videoUrl});

  @override
  _HLSVideoPlayerState createState() => _HLSVideoPlayerState();
}

class _HLSVideoPlayerState extends State<HLSVideoPlayer> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
      liveStream: false, // Set to true if it's a live stream
    );

    _betterPlayerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSkips: false,
          enablePlayPause: true,
          enableFullscreen: true,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'HLS Video Player',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 9,
          child: BetterPlayer(
            controller: _betterPlayerController,
          ),
        ),
      ),
    );
  }
}
