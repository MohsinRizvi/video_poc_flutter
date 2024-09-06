import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_poc/api_service.dart';
import 'package:video_poc/controller_provider.dart';
import 'package:video_poc/full_view.dart';
import 'package:video_poc/story_model.dart';
import 'package:video_poc/video_list_page.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  List<Story> stories = [];
  List<BetterPlayerController> controllers = [];
  var loading = true;
  final List<BetterPlayerController> resusableControllerList = [];

  late BetterPlayerController c1;
  late BetterPlayerController c2;

  int currentVideoIndex = 0;

  // setup() {
  //   print('PLAYING $currentVideoIndex VIDEO');
  //   c1 = createController(stories[currentVideoIndex].url);
  //   // c2 = createController(stories[currentVideoIndex + 1].url);
  //   if (currentVideoIndex < stories.length) {
  //     c1.addEventsListener((event) async {
  //       final position = await c1.videoPlayerController!.position;
  //       if (position!.inSeconds == 3) {
  //         c1.pause();
  //         stories[currentVideoIndex].isPlayed = true;
  //         currentVideoIndex++;
  //         setState(() {});
  //         c1.dispose();
  //         setup();
  //       }
  //     });
  //   }
  //   // c2.addEventsListener((event) {});
  // }

  // void getStories() async {
  //   var temp = await storyService.fetchStories();
  //   for (int i = 0; i < 11; i++) {
  //     if (temp[i].videoFormat == 'avi') continue;
  //     stories.add(temp[i]);
  //   }
  //   setup();
  //   // setupControllers();
  //   // setupReusableControllers();
  //   setState(() {
  //     loading = false;
  //   });
  // }

  // setupReusableControllers() {
  //   for (int i = 0; i < 3; i++) {
  //     resusableControllerList.add(createController(videoUrls[i]));
  //   }
  // }

  // BetterPlayerController createController(String url) {
  //   BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
  //     BetterPlayerDataSourceType.network,
  //     url,
  //     bufferingConfiguration: const BetterPlayerBufferingConfiguration(
  //       minBufferMs: 2000,
  //       maxBufferMs: 10000,
  //       bufferForPlaybackMs: 1000,
  //       bufferForPlaybackAfterRebufferMs: 2000,
  //     ),
  //     cacheConfiguration: const BetterPlayerCacheConfiguration(
  //       useCache: true,
  //       preCacheSize: 3 * 1024 * 1024,
  //       maxCacheSize: 100 * 1024 * 1024,
  //       maxCacheFileSize: 10 * 1024 * 1024,
  //     ),
  //   );
  //   return BetterPlayerController(
  //     const BetterPlayerConfiguration(
  //       aspectRatio: 2 / 3,
  //       fit: BoxFit.fitHeight,
  //       autoDispose: false,
  //       autoPlay: true,
  //       controlsConfiguration: BetterPlayerControlsConfiguration(
  //         controlBarColor: Colors.black26,
  //         showControls: false,
  //       ),
  //     ),
  //     betterPlayerDataSource: betterPlayerDataSource,
  //   );
  // }

  // void updateController(int newIndex) {
  //   // Calculate which controller to reuse
  //   int controllerToReuse = newIndex % 3;

  //   // Pause and dispose the current controller
  //   resusableControllerList[controllerToReuse].pause();
  //   resusableControllerList[controllerToReuse].dispose();

  //   // Create a new controller for the newIndex
  //   resusableControllerList[controllerToReuse] =
  //       createController(videoUrls[newIndex]);
  // }

  // void setupControllers() {
  //   for (int i = 0; i < stories.length; i++) {
  //     BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
  //       BetterPlayerDataSourceType.network,
  //       stories[i].url,
  //       bufferingConfiguration: const BetterPlayerBufferingConfiguration(
  //         minBufferMs: 2000,
  //         maxBufferMs: 10000,
  //         bufferForPlaybackMs: 1000,
  //         bufferForPlaybackAfterRebufferMs: 2000,
  //       ),
  //       cacheConfiguration: const BetterPlayerCacheConfiguration(
  //         useCache: true,
  //         preCacheSize: 3 * 1024 * 1024,
  //         maxCacheSize: 100 * 1024 * 1024,
  //         maxCacheFileSize: 10 * 1024 * 1024,
  //       ),
  //     );
  //     controllers.add(
  //       BetterPlayerController(
  //         const BetterPlayerConfiguration(
  //           aspectRatio: 2 / 3,
  //           fit: BoxFit.fitHeight,
  //           autoDispose: false,
  //           autoPlay: false,
  //           controlsConfiguration: const BetterPlayerControlsConfiguration(
  //             controlBarColor: Colors.black26,
  //             showControls: false,
  //           ),
  //         ),
  //         betterPlayerDataSource: betterPlayerDataSource,
  //       ),
  //     );
  //   }
  // }

  // List<String> videoUrls = [
  //   'https://nextgeni-951975770.imgix.net//elephants-dream.webm',
  //   'https://nextgeni-951975770.imgix.net/big-buck-bunny_trailer.webm',
  //   'https://nextgeni-951975770.imgix.net/file_example_WEBM_1280_3_6MB.webm',
  //   'https://nextgeni-951975770.imgix.net/h22c07ccf_2931378.mov',
  //   'https://nextgeni-951975770.imgix.net/MOV2811613.mov',
  //   'https://nextgeni-951975770.imgix.net/SampleVideo_1280x720_10mb.mp4',
  //   'https://nextgeni-951975770.imgix.net/sampoles.mp4',
  //   'https://nextgeni-951975770.imgix.net/3mb.mp4',
  //   'https://nextgeni-951975770.imgix.net/one-mp4.mp4',
  //   //
  //   'https://nextgeni-951975770.imgix.net//elephants-dream.webm',
  //   'https://nextgeni-951975770.imgix.net/big-buck-bunny_trailer.webm',
  //   'https://nextgeni-951975770.imgix.net/file_example_WEBM_1280_3_6MB.webm',
  //   'https://nextgeni-951975770.imgix.net/h22c07ccf_2931378.mov',
  //   'https://nextgeni-951975770.imgix.net/MOV2811613.mov',
  // ];

  @override
  void initState() {
    super.initState();
    // getStories();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Provider.of<ControllerProvider>(context, listen: false)
          .fetchStories(),
    );
  }

  void onTap(url) async {
    Provider.of<ControllerProvider>(context, listen: false)
        .disposeCurrentControllerAndCreateNew(url);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenView(),
      ),
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
      child: VisibilityDetector(
        key: UniqueKey(),
        onVisibilityChanged: (visibilityInfo) {
          // var visiblePercentage = visibilityInfo.visibleFraction * 100;
          // if (visiblePercentage >= 80) {
          //   widget.controller.play();
          // } else {
          //   widget.controller.pause();
          // }
        },
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
      ),
    );
  }
}

// class PlayListExample extends StatefulWidget {
//   const PlayListExample({super.key});

//   @override
//   State<PlayListExample> createState() => _PlayListExampleState();
// }

// class _PlayListExampleState extends State<PlayListExample> {
//   List<BetterPlayerDataSource> dataSourceList = [];

//   List<BetterPlayerDataSource> createDataSet() {
//     dataSourceList.add(
//       BetterPlayerDataSource(
//         BetterPlayerDataSourceType.network,
//         'https://ik.imagekit.io/oufxv7o9g/kinto/SampleVideo_1280x720_10mb.mp4?updatedAt=1718960900230',
//       ),
//     );
//     dataSourceList.add(
//       BetterPlayerDataSource(
//         BetterPlayerDataSourceType.network,
//         'https://ik.imagekit.io/oufxv7o9g/kinto/3mb.mp4?updatedAt=1725369991182',
//       ),
//     );
//     dataSourceList.add(
//       BetterPlayerDataSource(
//         BetterPlayerDataSourceType.network,
//         'https://ik.imagekit.io/oufxv7o9g/kinto/sampoles.mp4?updatedAt=1725370107581',
//         cacheConfiguration: const BetterPlayerCacheConfiguration(
//           useCache: true,
//           preCacheSize: 1 * 1024 * 1024,
//           maxCacheSize: 100 * 1024 * 1024,
//           maxCacheFileSize: 10 * 1024 * 1024,
//         ),
//       ),
//     );
//     return dataSourceList;
//   }

//   @override
//   void initState() {
//     super.initState();
//     createDataSet();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BetterPlayerPlaylist(
//       betterPlayerConfiguration: BetterPlayerConfiguration(),
//       betterPlayerPlaylistConfiguration:
//           const BetterPlayerPlaylistConfiguration(),
//       betterPlayerDataSourceList: dataSourceList,
//     );
//   }
// }

// // class VideoWidget extends StatefulWidget {
// //   const VideoWidget({
// //     super.key,
// //     required this.videoUrls,
// //   });

// //   final String videoUrls;

// //   @override
// //   State<VideoWidget> createState() => _VideoWidgetState();
// // }

// // class _VideoWidgetState extends State<VideoWidget> {
// //   BetterPlayerConfiguration? betterPlayerConfiguration;
// //   BetterPlayerListVideoPlayerController? controller =
// //       BetterPlayerListVideoPlayerController();

// //   @override
// //   void initState() {
// //     // TODO: implement initState
// //     super.initState();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return SizedBox(
// //       child: BetterPlayerListVideoPlayer(
// //         autoPlay: false,
// //         BetterPlayerDataSource(
// //           cacheConfiguration: const BetterPlayerCacheConfiguration(
// //             useCache: true,
// //             preCacheSize: 1 * 1024 * 1024,
// //             maxCacheSize: 100 * 1024 * 1024,
// //             maxCacheFileSize: 10 * 1024 * 1024,
// //           ),
// //           BetterPlayerDataSourceType.network,
// //           widget.videoUrls,
// //           bufferingConfiguration: const BetterPlayerBufferingConfiguration(
// //             minBufferMs: 2000,
// //             maxBufferMs: 10000,
// //             bufferForPlaybackMs: 1000,
// //             bufferForPlaybackAfterRebufferMs: 2000,
// //           ),
// //         ),
// //         configuration: const BetterPlayerConfiguration(
// //           aspectRatio: 2 / 3,
// //           fit: BoxFit.fitHeight,
// //           autoPlay: false,
// //           controlsConfiguration: BetterPlayerControlsConfiguration(
// //             controlBarColor: Colors.black26,
// //             showControls: false,
// //           ),
// //         ),
// //         playFraction: 1.0,
// //         betterPlayerListVideoPlayerController: controller,
// //       ),
// //     );
// //   }
// // }
