import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ReelsScreen(),
    );
  }
}

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  List<String> videoUrls = [
    'https://assets.mixkit.co/videos/1259/1259-720.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-woman-turning-off-her-alarm-clock-42897-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-pair-of-plantain-stalks-in-a-close-up-shot-42956-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-aerial-view-of-city-traffic-at-night-11-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-countryside-meadow-4075-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-texture-of-different-fruits-42959-large.mp4',
  ];

  List<BetterPlayerController> controllers = [];

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    for (var url in videoUrls) {
      final controller = BetterPlayerController(
        BetterPlayerConfiguration(
          // aspectRatio: 16 / 9,
          autoPlay: false,
          looping: false,
          handleLifecycle: true,
        ),
        betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          url,
          cacheConfiguration: BetterPlayerCacheConfiguration(
            useCache: true,
            preCacheSize: 10 * 1024 * 1024, // 10 MB
            maxCacheSize: 100 * 1024 * 1024, // 100 MB
            maxCacheFileSize: 10 * 1024 * 1024, // 10 MB
            key: url,
          ), // Unique cache key per video)
        ),
      );
      controllers.add(controller);
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video List'),
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          return VideoWidget(videoUrls: videoUrls[index]);
        },
      ),
    );
  }
}

class VideoWidget extends StatefulWidget {
  const VideoWidget({
    super.key,
    required this.videoUrls,
  });

  final String videoUrls;

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  BetterPlayerConfiguration? betterPlayerConfiguration;
  BetterPlayerListVideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    controller = BetterPlayerListVideoPlayerController();
    betterPlayerConfiguration = BetterPlayerConfiguration(autoPlay: true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BetterPlayerListVideoPlayer(
      BetterPlayerDataSource(
        cacheConfiguration: BetterPlayerCacheConfiguration(
          useCache: true,
          preCacheSize: 1 * 1024 * 1024, // 10 MB
          maxCacheSize: 100 * 1024 * 1024, // 100 MB
          maxCacheFileSize: 10 * 1024 * 1024, // 10 MB
          // key: url,
        ),
        BetterPlayerDataSourceType.network,
        widget.videoUrls,
        bufferingConfiguration: BetterPlayerBufferingConfiguration(
          minBufferMs: 2000,
          maxBufferMs: 10000,
          bufferForPlaybackMs: 1000,
          bufferForPlaybackAfterRebufferMs: 2000,
        ),
      ),
      configuration: BetterPlayerConfiguration(
        // aspectRatio: 9 / 16,
        fit: BoxFit.fitHeight,
        autoPlay: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          controlBarColor: Colors.black26,
        ),
      ),
      playFraction: 0.8,
      betterPlayerListVideoPlayerController: controller,
    );
  }
}
