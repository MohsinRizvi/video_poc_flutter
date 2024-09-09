import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_poc/models/story_model.dart';
import 'package:video_poc/service/network.dart';

class ControllerProvider extends ChangeNotifier {
  var currentIndexPlaying = 0;
  var currentReelIndex = 0;
  var loading = true;
  late BetterPlayerController c1;
  late BetterPlayerController c2;
  var pageController = PageController();
  final StoryService storyService = StoryService();
  List<Story> stories = [];

  void fetchStories() async {
    stories = await storyService.fetchStories();
    // if (Platform.isAndroid) {
    //   stories.retainWhere((story) => story.videoFormat == 'webm');
    // }
    if (Platform.isIOS) {
      stories.removeWhere((story) =>
          story.videoFormat == 'webm' ||
          story.videoFormat == 'webm-vp9' ||
          story.videoFormat == 'mp4');
    }
    // stories = [stories[3], stories[3], stories[3], stories[3]];
    await Future.delayed(const Duration(seconds: 2));
    loading = false;

    setupController();
    notifyListeners();
  }

  void setupController() async {
    debugPrint('PLAYING $currentIndexPlaying VIDEO');

    c1 = createController(stories[currentIndexPlaying].url);
    c1.setVolume(0);
    if (currentIndexPlaying >= stories.length) {
      await c1.preCache(initDataSource(stories[currentIndexPlaying + 1].url));
    }

    c1.addEventsListener((event) async {
      final position = c1.videoPlayerController!.value.position;
      if (position != null && position.inSeconds >= 3) {
        c1.pause();
        stories[currentIndexPlaying].isPlayed = true;
        currentIndexPlaying++;

        notifyListeners();

        if (currentIndexPlaying >= stories.length) {
          currentIndexPlaying = 0;
        }
        c1.removeEventsListener((event) {});
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
      BetterPlayerConfiguration(
        placeholder: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: stories[currentIndexPlaying].thumbnail,
          placeholder: (context, url) => const SizedBox(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        aspectRatio: 2 / 3.8,
        fit: BoxFit.cover,
        autoDispose: false,
        autoPlay: true,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          controlBarColor: Colors.black26,
          showControls: false,
        ),
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );
  }

  createReelsController(String url) {
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
      BetterPlayerConfiguration(
        placeholder: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: stories[currentIndexPlaying].thumbnail,
          placeholder: (context, url) => const SizedBox(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        aspectRatio: 2 / 3.8,
        fit: BoxFit.cover,
        autoDispose: false,
        autoPlay: true,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          controlBarColor: Colors.black26,
          showControls: true,
          enableFullscreen: false,
          enableProgressBar: false,
        ),
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );
  }

  disposeCurrentControllerAndCreateNew(String url, {int reelIndex = 0}) {
    currentReelIndex = reelIndex;
    pageController = PageController(initialPage: reelIndex);
    c2 = createReelsController(url);

    c2.addEventsListener((event) {
      if (c2.isVideoInitialized()!) notifyListeners();
      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        currentReelIndex++;
        pageController.jumpToPage(currentReelIndex);
      }
    });
    c1.pause();
  }

  onPageChange(int index, String url) {
    currentReelIndex = index;

    c2.dispose(forceDispose: true);
    c2 = createReelsController(url);
    c2.addEventsListener((event) {
      if (c2.isVideoInitialized()!) notifyListeners();
      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        currentReelIndex++;
        pageController.jumpToPage(currentReelIndex);
      }
    });
    notifyListeners();
  }

  resumeC1() {
    c2.dispose(forceDispose: true);
    c1.play();
  }

  BetterPlayerDataSource initDataSource(String url) {
    return BetterPlayerDataSource(
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
  }
}

class VideoSize {
  final int bytes;
  final double megabytes;

  VideoSize(this.bytes, this.megabytes);
}
