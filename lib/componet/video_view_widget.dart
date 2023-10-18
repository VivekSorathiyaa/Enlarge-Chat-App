import 'dart:developer';
import 'dart:io';
import 'package:chatapp/utils/colors.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoViewWidget extends StatefulWidget {
  const VideoViewWidget({Key? key, required this.url, required this.isFile})
      : super(key: key);
  final String url;
  final bool isFile;

  @override
  State<VideoViewWidget> createState() => _VideoViewWidgetState();
}

class _VideoViewWidgetState extends State<VideoViewWidget>
    with AutomaticKeepAliveClientMixin {
  bool isInitialized = false;
  double aspectRatio = 0;
  ChewieController? chewieController;

  @override
  bool get wantKeepAlive => false;

  loadVideo() async {
    final videoPlayerController;
    if (widget.isFile) {
      videoPlayerController = VideoPlayerController.file(File(widget.url));
    } else {
      videoPlayerController = VideoPlayerController.network(widget.url);
    }

    await videoPlayerController.initialize();

    aspectRatio = videoPlayerController.value.aspectRatio;

    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoInitialize: true,
        zoomAndPan: false,
        showOptions: false,
        autoPlay: true,
        allowFullScreen: false,
        // showControls: false,
        // showControlsOnInitialize: false,
        fullScreenByDefault: true,
        hideControlsTimer: const Duration(seconds: 1));
    setState(() {
      isInitialized = true;
    });
  }

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  @override
  void dispose() {
    chewieController?.pause();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Builder(
        builder: (context) => (isInitialized && chewieController != null)
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: primaryBlack,
                child: Stack(
                  children: [
                    Chewie(controller: chewieController!),
                  ],
                ),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: primaryBlack,
                child: const Center(
                    child: CircularProgressIndicator(color: primaryWhite)),
              ),
      ),
    );
  }
}
