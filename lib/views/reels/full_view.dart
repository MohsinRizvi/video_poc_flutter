import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_poc/controller/controller_provider.dart';

class FullScreenView extends StatelessWidget {
  final double index;
  const FullScreenView({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Consumer<ControllerProvider>(
          builder: (context, provider, _) {
            return PopScope(
              onPopInvokedWithResult: (didPop, result) {
                provider.resumeC1();
              },
              child: PageView.builder(
                controller: provider.pageController,
                itemCount: provider.stories.length,
                onPageChanged: (index) {
                  provider.onPageChange(index, provider.stories[index].url);
                },
                itemBuilder: (context, index) {
                  return index != provider.currentReelIndex
                      ? CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: provider.stories[index].thumbnail,
                          placeholder: (context, url) => const SizedBox(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : provider.c2.isVideoInitialized()!
                          ? AspectRatio(
                              aspectRatio: 16 / 9,
                              child: BetterPlayer(controller: provider.c2))
                          : Container();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({
    super.key,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  @override
  void initState() {
    print("INIT CALLED FROM VIDEO PLAYER");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ControllerProvider>(builder: (context, provider, _) {
      return FittedBox(
        fit: BoxFit.cover,
        child: provider.c2.isVideoInitialized()!
            ? SizedBox(
                width: provider.c2.videoPlayerController!.value.size!.width,
                height: provider.c2.videoPlayerController!.value.size!.height,
                child: BetterPlayer(controller: provider.c2),
              )
            : SizedBox(),
      );
    });
  }
}
