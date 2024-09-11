import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../animation/animated_bar.dart';
import '../../models/story_model.dart';
import '../../service/network.dart';

class StoryScreen extends StatefulWidget {
  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  VideoPlayerController? _videoController;
  int _currentIndex = 0;
  List<Story> _stories = [];
  bool _isLoading = true;

  final StoryService _storyService = StoryService();

  @override
  initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(vsync: this);
    _fetchStories();

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setState(() {
          if (_currentIndex + 1 < _stories.length) {
            _currentIndex += 1;
            _loadStory(story: _stories[_currentIndex]);
          } else {
            // Loop back to the first story
            _currentIndex = 0;
            _loadStory(story: _stories[_currentIndex]);
          }
        });
      }
    });
  }

  bool _isSupportedVideoFormat(String format) {
    return format == 'mp4' ||
        format == 'mov' ||
        format == '3pg'; // Add other supported formats if needed
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_stories.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'No stories available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final Story story = _stories[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) => _onTapDown(details, story),
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stories.length,
              itemBuilder: (context, i) {
                print("STORIES LENGTH==========>${_stories.length}");
                final Story story = _stories[i];

                switch (story.media) {
                  case MediaType.image:
                    return CachedNetworkImage(
                      imageUrl: story.thumbnail,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    );

                  case MediaType.video:
                    // Check if video controller is initialized
                    if (_videoController != null &&
                        _videoController!.value.isInitialized) {
                      return FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController!.value.size.width,
                          height: _videoController!.value.size.height,
                          child: VideoPlayer(_videoController!),
                        ),
                      );
                    } else {
                      // Show blurred thumbnail with a loader
                      return Stack(
                        children: [
                          // Blurred thumbnail
                          CachedNetworkImage(
                            imageUrl: story.thumbnail,
                            fit: BoxFit.cover,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Container(
                              color: Colors.black,
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          // Loader at the center
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    }
                }
              },
            ),
            Positioned(
              top: 40.0,
              left: 10.0,
              right: 10.0,
              child: Column(
                children: <Widget>[
                  Row(
                    children: _stories
                        .asMap()
                        .map((i, e) {
                          return MapEntry(
                            i,
                            AnimatedBar(
                              animController: _animController,
                              position: i,
                              currentIndex: _currentIndex,
                            ),
                          );
                        })
                        .values
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details, Story story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex -= 1;
          _loadStory(story: _stories[_currentIndex]);
        }
      });
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        if (_currentIndex + 1 < _stories.length) {
          _currentIndex += 1;
          _loadStory(story: _stories[_currentIndex]);
        } else {
          _currentIndex = 0;
          _loadStory(story: _stories[_currentIndex]);
        }
      });
    } else {
      if (story.media == MediaType.video) {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
          _animController.stop();
        } else {
          _videoController!.play();
          _animController.forward();
        }
      }
    }
  }

  void _fetchStories() async {
    try {
      _isLoading = true;
      final stories = await _storyService.fetchStories();
      setState(() {
        // _stories = stories.where((story) => _isSupportedVideoFormat(story.videoFormat)).toList();

        _stories = stories.toList();
        _isLoading = false;

        // Pre-cache the first few seconds of each video
        for (var story in _stories) {
          if (story.media == MediaType.video) {
            _preCacheVideo(story.url);
          }
        }

        if (_stories.isNotEmpty) {
          _loadStory(story: _stories.first, animateToPage: false);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (e.g., show a snack bar)
    }
  }

  void _preCacheVideo(String url) {
    final videoController = VideoPlayerController.network(url);
    videoController.initialize().then((_) {
      // Set the playback speed to 0 to avoid starting playback
      videoController.setPlaybackSpeed(0.1);

      // Play the first 3 seconds
      videoController.play();
      Future.delayed(const Duration(seconds: 3), () {
        videoController.pause();
        videoController.seekTo(Duration.zero);
        videoController.setPlaybackSpeed(1.0); // Reset to normal speed
        videoController.dispose();
      });
    }).catchError((error) {
      // Handle initialization errors
      print('Video pre-cache error: $error');
    });
  }

// Method to get video size
  Future<VideoSize> _getVideoSize(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      final contentLength = response.headers['content-length'];
      final sizeInBytes = contentLength != null ? int.parse(contentLength) : 0;
      final sizeInMB = sizeInBytes / (1024 * 1024);

      return VideoSize(sizeInBytes, sizeInMB);
    } catch (error) {
      print('Error fetching video size: $error');
      return VideoSize(0, 0);
    }
  }

  void _loadStory({required Story story, bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();
    DateTime loadStartTime = DateTime.now();
    switch (story.media) {
      case MediaType.image:
        _animController.duration =
            const Duration(seconds: 3); // Display image for 3 seconds
        _animController.forward();
        break;

      case MediaType.video:
        _videoController?.dispose();
        _videoController = VideoPlayerController.network(story.url)
          ..initialize().then((_) async {
            setState(() {}); // Rebuild to show the video
            if (_videoController!.value.isInitialized) {
              Duration loadTime = DateTime.now().difference(loadStartTime);

              // Display Snackbars for format, load time, and duration
              // Fetch video size
              Future<VideoSize> _getVideoSize(String url) async {
                try {
                  final response = await http.head(Uri.parse(url));
                  final contentLength = response.headers['content-length'];
                  final sizeInBytes =
                      contentLength != null ? int.parse(contentLength) : 0;
                  final sizeInMB = sizeInBytes / (1024 * 1024);

                  return VideoSize(sizeInBytes, sizeInMB);
                } catch (error) {
                  print('Error fetching video size: $error');
                  return VideoSize(0, 0);
                }
              }

              final videoSize = await _getVideoSize(story.url);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Video Format: ${story.videoFormat.toUpperCase()} - Load Time: ${loadTime.inMilliseconds} ms - Duration: ${_videoController!.value.duration.inSeconds} seconds - Size: ${videoSize.bytes} bytes (${videoSize.megabytes.floor()} MB)',
                  ),
                  duration: Duration(seconds: 3),
                ),
              );

              _animController.duration = _videoController!.value.duration +
                  const Duration(seconds: 3); // Add 3 seconds buffer
              _videoController!.play();
              _animController.forward();
            }
          }).catchError((error) {
            // Handle initialization errors
            print('Video initialization error: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to load video. Please try again.'),
                duration: Duration(seconds: 2),
              ),
            );
          });
        break;
    }

    if (animateToPage) {
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }
}

class VideoSize {
  final int bytes;
  final double megabytes;

  VideoSize(this.bytes, this.megabytes);
}
