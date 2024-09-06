import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_poc/controller/controller_provider.dart';

class FullScreenView extends StatelessWidget {
  const FullScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ControllerProvider>(builder: (context, provider, _) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            provider.resumeC1();
          },
          child: PageView.builder(
            // physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.stories.length,
            onPageChanged: (value) {
              provider.disposeCurrentControllerAndCreateNew(
                  provider.stories[provider.currentIndexPlaying + 1].url);
            },
            itemBuilder: (context, index) {
              return VideoPlayer();
            },
          ),
        );
      }),
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
