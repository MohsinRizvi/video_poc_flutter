import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_poc/controller_provider.dart';

class FullScreenView extends StatelessWidget {
  final BetterPlayerController controller;
  const FullScreenView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AspectRatio(
        aspectRatio: controller.getAspectRatio() ?? 9 / 16,
        child: Consumer<ControllerProvider>(builder: (context, provider, _) {
          return BetterPlayer(controller: provider.c1);
        }),
      ),
    );
  }
}
