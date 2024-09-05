import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:video_poc/reusable_video_controller.dart';
import 'package:video_poc/video_model.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReusableVideoListWidget extends StatefulWidget {
  final VideoListData? videoListData;
  final ReusableVideoListController? videoListController;
  final Function? canBuildVideo;

  const ReusableVideoListWidget({
    Key? key,
    this.videoListData,
    this.videoListController,
    this.canBuildVideo,
  }) : super(key: key);

  @override
  _ReusableVideoListWidgetState createState() =>
      _ReusableVideoListWidgetState();
}

class _ReusableVideoListWidgetState extends State<ReusableVideoListWidget> {
  VideoListData? get videoListData => widget.videoListData;
  BetterPlayerController? controller;
  StreamController<BetterPlayerController?>
      betterPlayerControllerStreamController = StreamController.broadcast();
  bool _initialized = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    betterPlayerControllerStreamController.close();
    super.dispose();
  }

  void _setupController() {
    if (controller == null) {
      controller = widget.videoListController!.getBetterPlayerController();
      final configuration = BetterPlayerControlsConfiguration(
        controlBarColor: Colors.black26,
      );
      if (controller != null) {
        controller!.setBetterPlayerControlsConfiguration(configuration);
        controller!.setupDataSource(
          BetterPlayerDataSource.network(
            videoListData!.videoUrl,
            cacheConfiguration: BetterPlayerCacheConfiguration(
              useCache: true,
              preCacheSize: 1 * 1024 * 1024,
              maxCacheSize: 100 * 1024 * 1024,
              maxCacheFileSize: 10 * 1024 * 1024,
            ),
            bufferingConfiguration: BetterPlayerBufferingConfiguration(
              minBufferMs: 2000,
              maxBufferMs: 10000,
              bufferForPlaybackMs: 1000,
              bufferForPlaybackAfterRebufferMs: 2000,
            ),
          ),
        );
        if (!betterPlayerControllerStreamController.isClosed) {
          betterPlayerControllerStreamController.add(controller);
        }
        controller!.addEventsListener(onPlayerEvent);
      }
    }
  }

  void _freeController() {
    if (!_initialized) {
      _initialized = true;
      return;
    }
    if (controller != null && _initialized) {
      controller!.removeEventsListener(onPlayerEvent);
      widget.videoListController!.freeBetterPlayerController(controller);
      controller!.pause();
      controller = null;
      if (!betterPlayerControllerStreamController.isClosed) {
        betterPlayerControllerStreamController.add(null);
      }
      _initialized = false;
    }
  }

  void onPlayerEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
      videoListData!.lastPosition = event.parameters!["progress"] as Duration?;
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      if (videoListData!.lastPosition != null) {
        controller!.seekTo(videoListData!.lastPosition!);
      }
      if (videoListData!.wasPlaying!) {
        controller!.play();
      }
    }
  }

  ///TODO: Handle "setState() or markNeedsBuild() called during build." error
  ///when fast scrolling through the list
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              videoListData!.videoTitle,
              style: TextStyle(fontSize: 50),
            ),
          ),
          VisibilityDetector(
            key: Key(hashCode.toString() + DateTime.now().toString()),
            onVisibilityChanged: (info) {
              if (!widget.canBuildVideo!()) {
                _timer?.cancel();
                _timer = null;
                _timer = Timer(Duration(milliseconds: 500), () {
                  if (info.visibleFraction >= 0.6) {
                    _setupController();
                  } else {
                    _freeController();
                  }
                });
                return;
              }
              if (info.visibleFraction >= 0.6) {
                _setupController();
              } else {
                _freeController();
              }
            },
            child: StreamBuilder<BetterPlayerController?>(
              stream: betterPlayerControllerStreamController.stream,
              builder: (context, snapshot) {
                return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: controller != null
                      ? BetterPlayer(
                          controller: controller!,
                        )
                      : Container(
                          color: Colors.black,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
                "Horror: In Steven Spielberg's Jaws, a shark terrorizes a beach "
                "town. Plainspoken sheriff Roy Scheider, hippie shark "
                "researcher Richard Dreyfuss, and a squirrely boat captain "
                "set out to find the beast, but will they escape with their "
                "lives? 70's special effects, legendary score, and trademark "
                "humor set this classic apart."),
          ),
          Center(
            child: Wrap(children: [
              ElevatedButton(
                child: Text("Play"),
                onPressed: () {
                  controller!.play();
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                child: Text("Pause"),
                onPressed: () {
                  controller!.pause();
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                child: Text("Set max volume"),
                onPressed: () {
                  controller!.setVolume(1.0);
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  void deactivate() {
    if (controller != null) {
      videoListData!.wasPlaying = controller!.isPlaying();
    }
    _initialized = true;
    super.deactivate();
  }
}

class VideoListingPage extends StatefulWidget {
  const VideoListingPage({super.key});

  @override
  State<VideoListingPage> createState() => _VideoListingPageState();
}

class _VideoListingPageState extends State<VideoListingPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
