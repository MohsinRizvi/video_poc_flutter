import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_poc/controller/controller_provider.dart';
import 'package:video_poc/views/reels/full_view.dart';
import 'package:video_poc/service/network.dart';

import '../stories/stories.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'POC REELS',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Consumer<ControllerProvider>(
              builder: (context, provider, _) {
                return provider.loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.stories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        provider.setCurrentStory(index);
                        Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StoryScreen(),
                              ),
                            );

                        // Provider.of<ControllerProvider>(context, listen: false)
                        //     .disposeCurrentControllerAndCreateNew(provider.stories[index].url);
                        //
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => FullScreenView(),
                        //   ),
                        // );
                        // Add logic to play story on click
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: provider.stories[index].thumbnail,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<ControllerProvider>(
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
          ),
        ],
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