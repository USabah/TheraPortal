import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewWidget extends StatelessWidget {
  final Uint8List? mediaContent;
  final String? mediaPath;

  const MediaPreviewWidget({Key? key, this.mediaContent, this.mediaPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (mediaContent != null) {
      // Check if the media content is video or image
      if (mediaPath != null &&
          (mediaPath!.toLowerCase().endsWith('.mp4') ||
              mediaPath!.toLowerCase().endsWith('.mov') ||
              mediaPath!.toLowerCase().endsWith('.avi') ||
              mediaPath!.toLowerCase().endsWith('.mkv'))) {
        return VideoPreview(mediaContent: mediaContent!);
      } else {
        return ImagePreview(mediaContent: mediaContent!);
      }
    } else {
      return const SizedBox.shrink(); // Empty widget if no media content
    }
  }
}

class VideoPreview extends StatefulWidget {
  final Uint8List mediaContent;

  const VideoPreview({Key? key, required this.mediaContent}) : super(key: key);

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    final videoFile = File('${Directory.systemTemp.path}/temp_video.mp4');
    await videoFile.writeAsBytes(widget.mediaContent);
    _controller = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        _controller!.play();
        _controller!.setLooping(true);

        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null && _controller!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      );
    } else {
      return const CircularProgressIndicator(); // Or any loading indicator
    }
  }
}

class ImagePreview extends StatelessWidget {
  final Uint8List mediaContent;

  const ImagePreview({Key? key, required this.mediaContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      mediaContent,
      fit: BoxFit.cover,
    );
  }
}
