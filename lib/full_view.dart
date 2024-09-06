import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_poc/controller_provider.dart';

class FullScreenView extends StatelessWidget {
  const FullScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ControllerProvider>(builder: (context, provider, _) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            provider.resumeC1();
          },
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: BetterPlayer(controller: provider.c2),
          ),
        );
      }),
    );
  }
}
