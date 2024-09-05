import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_poc/video_list_widget.dart';
import 'package:video_poc/video_model.dart';

import 'reusable_video_controller.dart';

class ReusableVideoListPage extends StatefulWidget {
  const ReusableVideoListPage({super.key});

  @override
  _ReusableVideoListPageState createState() => _ReusableVideoListPageState();
}

class _ReusableVideoListPageState extends State<ReusableVideoListPage> {
  ReusableVideoListController videoListController =
      ReusableVideoListController();
  final _random = Random();
  List<String> videoUrls = [
    // 'https://assets.mixkit.co/videos/1259/1259-720.mp4',
    // 'https://assets.mixkit.co/videos/preview/mixkit-woman-turning-off-her-alarm-clock-42897-large.mp4',
    // 'https://assets.mixkit.co/videos/preview/mixkit-pair-of-plantain-stalks-in-a-close-up-shot-42956-large.mp4',
    // 'https://assets.mixkit.co/videos/preview/mixkit-aerial-view-of-city-traffic-at-night-11-large.mp4',
    // 'https://assets.mixkit.co/videos/preview/mixkit-countryside-meadow-4075-large.mp4',
    // 'https://assets.mixkit.co/videos/preview/mixkit-texture-of-different-fruits-42959-large.mp4',

    //

    'https://ik.imagekit.io/oufxv7o9g/kinto/SampleVideo_1280x720_10mb.mp4?updatedAt=1718960900230',
    'https://ik.imagekit.io/oufxv7o9g/kinto/3mb.mp4?updatedAt=1725369991182',
    'https://ik.imagekit.io/oufxv7o9g/kinto/sampoles.mp4?updatedAt=1725370107581'
  ];

  List<VideoListData> dataList = [];

  var value = 0;
  final ScrollController _scrollController = ScrollController();
  int lastMilli = DateTime.now().millisecondsSinceEpoch;
  bool _canBuildVideo = true;

  @override
  void initState() {
    _setupData();
    super.initState();
  }

  void _setupData() {
    for (int index = 0; index < 5; index++) {
      var randomVideoUrl = videoUrls[_random.nextInt(videoUrls.length)];
      dataList.add(VideoListData("Video $index", randomVideoUrl));
    }
  }

  @override
  void dispose() {
    videoListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reusable video list")),
      body: Container(
        color: Colors.grey,
        child: Column(children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                final now = DateTime.now();
                final timeDiff = now.millisecondsSinceEpoch - lastMilli;
                if (notification is ScrollUpdateNotification) {
                  final pixelsPerMilli = notification.scrollDelta! / timeDiff;
                  if (pixelsPerMilli.abs() > 1) {
                    _canBuildVideo = false;
                  } else {
                    _canBuildVideo = true;
                  }
                  lastMilli = DateTime.now().millisecondsSinceEpoch;
                }

                if (notification is ScrollEndNotification) {
                  _canBuildVideo = true;
                  lastMilli = DateTime.now().millisecondsSinceEpoch;
                }

                return true;
              },
              child: ListView.builder(
                itemCount: dataList.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  VideoListData videoListData = dataList[index];
                  return ReusableVideoListWidget(
                    videoListData: videoListData,
                    videoListController: videoListController,
                    canBuildVideo: _checkCanBuildVideo,
                  );
                },
              ),
            ),
          )
        ]),
      ),
    );
  }

  bool _checkCanBuildVideo() {
    return _canBuildVideo;
  }
}
