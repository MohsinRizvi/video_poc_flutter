import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_poc/controller/controller_provider.dart';
import 'package:video_poc/views/reels/full_view.dart';
import 'package:video_poc/views/reels/splash_view.dart';

class VideoListView extends StatefulWidget {
  const VideoListView({super.key});

  @override
  State<VideoListView> createState() => _VideoListViewState();
}

class _VideoListViewState extends State<VideoListView> {
  @override
  void initState() {
    super.initState();
    Provider.of<ControllerProvider>(context, listen: false)
        .fetchStories(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ControllerProvider>(
      builder: (context, provider, _) {
        return provider.loading
            ? const SplashView()
            : Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  centerTitle: true,
                  title: const Text(
                    "Reels POC",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    Switch(
                      value: provider.showSnackBar,
                      onChanged: (value) {
                        provider.toggleSnacbar(value);
                      },
                    ),
                  ],
                ),
                body: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 2 / 3.8,
                  ),
                  itemCount: provider.stories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        provider.disposeCurrentControllerAndCreateNew(
                            provider.stories[index].url,
                            reelIndex: index);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenView(
                              index: double.parse(index.toString()),
                            ),
                          ),
                        );
                      },
                      child: index != provider.currentIndexPlaying
                          ? CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: provider.stories[index].thumbnail,
                              placeholder: (context, url) => const SizedBox(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            )
                          : BetterPlayer(controller: provider.c1),
                    );
                  },
                ),
              );
      },
    );
  }
}
