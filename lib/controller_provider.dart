import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:video_poc/api_service.dart';
import 'package:video_poc/story_model.dart';

class ControllerProvider extends ChangeNotifier {
  var currentIndexPlaying = 0;
  late BetterPlayerController c1;
  List<Story> stories = [];
  final StoryService storyService = StoryService();
  var loading = true;
  Duration? loadDateTime = Duration.zero;

  void fetchStories() async {
    var temp = await storyService.fetchStories();
    for (int i = 0; i < 11; i++) {
      if (temp[i].videoFormat == 'avi') continue;
      stories.add(temp[i]);
    }
    loading = false;
    setupController();
    notifyListeners();
  }

  void setupController() {
    print('PLAYING ${currentIndexPlaying} VIDEO');

    final currentTime = DateTime.now();

    c1 = createController(stories[currentIndexPlaying].url);

    c1.addEventsListener((event) async {
      print('Event Type: ${event.betterPlayerEventType}');
      if (event.betterPlayerEventType == BetterPlayerEventType.play) {
        loadDateTime = DateTime.now().difference(currentTime);
        print('LOAD TIME $loadDateTime');
      }
      final position = await c1.videoPlayerController!.position;
      if (position != null && position.inSeconds >= 3) {
        // Pause the video after 3 seconds
        c1.pause();
        stories[currentIndexPlaying].isPlayed = true;
        notifyListeners();

        // Move to the next video
        currentIndexPlaying++;
        if (currentIndexPlaying >= stories.length) {
          currentIndexPlaying = 0; // Loop back to the start
        }

        // // Reset all videos to their thumbnails except the current one
        // for (int i = 0; i < stories.length; i++) {
        //   if (i == currentIndexPlaying) continue;
        //   stories[i].isPlayed = false;
        // }

        notifyListeners();

        // Dispose the current controller and setup the new video

        c1.dispose(forceDispose: true);
        setupController();
      }
    });
  }

  BetterPlayerController createController(String url) {
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 3000,
        maxBufferMs: 10000,
        bufferForPlaybackMs: 1000,
        bufferForPlaybackAfterRebufferMs: 2000,
      ),
      cacheConfiguration: const BetterPlayerCacheConfiguration(
        useCache: true,
        preCacheSize: 3 * 1024 * 1024,
        maxCacheSize: 100 * 1024 * 1024,
        maxCacheFileSize: 10 * 1024 * 1024,
      ),
    );
    return BetterPlayerController(
      const BetterPlayerConfiguration(
        aspectRatio: 2 / 3,
        fit: BoxFit.fitHeight,
        autoDispose: false,
        autoPlay: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          controlBarColor: Colors.black26,
          showControls: false,
        ),
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );
  }

  disposeCurrentControllerAndCreateNew(String url) {
    c1.dispose(forceDispose: true);
    c1 = createController(url);
  }
}

class VideoSize {
  final int bytes;
  final double megabytes;

  VideoSize(this.bytes, this.megabytes);
}
