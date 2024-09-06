import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_poc/api_service.dart';
import 'package:video_poc/controller_provider.dart';
import 'package:video_poc/full_view.dart';

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
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ReelsScreen(),
      ),
    );
  }
}

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final StoryService storyService = StoryService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Provider.of<ControllerProvider>(context, listen: false)
          .fetchStories(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Video List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Consumer<ControllerProvider>(
        builder: (context, provider, _) {
          return provider.loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    itemCount: provider.stories.length,
                    itemBuilder: (context, index) {
                      return VideoWidget(
                        videoUrls: provider.stories[index].url,
                        controller: provider.c1,
                        thumbnail: provider.stories[index].thumbnail,
                        isPlaying: provider.stories[index].isPlayed,
                        index: index,
                        currentIndexPlaying: provider.currentIndexPlaying,
                        duration: provider.loadDateTime!,
                      );
                    },
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 3,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                    ),
                  ),
                );
        },
      ),
    );
  }
}

class VideoWidget extends StatefulWidget {
  const VideoWidget({
    super.key,
    required this.videoUrls,
    required this.controller,
    required this.thumbnail,
    required this.isPlaying,
    required this.index,
    required this.currentIndexPlaying,
    required this.duration,
  });

  final String videoUrls;
  final BetterPlayerController controller;

  final String thumbnail;
  final bool isPlaying;
  final int index, currentIndexPlaying;
  final Duration duration;

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  @override
  void dispose() {
    print("DISOPOSE CALLED FROM VIDEO WIDGET");

    super.dispose();
  }

  void onTap() async {
    Provider.of<ControllerProvider>(context, listen: false)
        .disposeCurrentControllerAndCreateNew(widget.videoUrls);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: widget.index != widget.currentIndexPlaying
          ? AspectRatio(
              aspectRatio: 2 / 3,
              child: Image.network(
                widget.thumbnail,
                fit: BoxFit.cover,
              ))
          : Stack(
              children: [
                BetterPlayerMultipleGestureDetector(
                    onTap: null,
                    child: BetterPlayer(controller: widget.controller)),
                Text(
                  widget.duration.inMilliseconds.toString(),
                  style: const TextStyle(fontSize: 30, color: Colors.red),
                ),
              ],
            ),
    );
  }
}
