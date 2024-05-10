import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewWidget extends StatelessWidget {
  final Uint8List? mediaContent;
  final String? mediaPath;

  const MediaPreviewWidget({super.key, this.mediaContent, this.mediaPath});

  @override
  Widget build(BuildContext context) {
    if (mediaContent != null) {
      bool isImage = true;
      // Check if the media content is video or image
      if (mediaPath != null &&
          (mediaPath!.toLowerCase().endsWith('.mp4') ||
              mediaPath!.toLowerCase().endsWith('.mov') ||
              mediaPath!.toLowerCase().endsWith('.avi') ||
              mediaPath!.toLowerCase().endsWith('.mkv'))) {
        isImage = false;
      }
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenPreview(
                mediaContent: mediaContent!,
                isImage: isImage,
              ),
            ),
          );
        },
        child: (isImage)
            ? ImagePreview(mediaContent: mediaContent!)
            : VideoPreview(mediaContent: mediaContent!),
      );
    } else {
      return const SizedBox.shrink(); // Empty widget if no media content
    }
  }
}

class VideoPreview extends StatefulWidget {
  final Uint8List mediaContent;

  const VideoPreview({super.key, required this.mediaContent});

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

  const ImagePreview({super.key, required this.mediaContent});

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      mediaContent,
      fit: BoxFit.cover,
    );
  }
}

class FullScreenPreview extends StatefulWidget {
  final Uint8List mediaContent;
  final bool isImage;

  const FullScreenPreview({
    Key? key,
    required this.mediaContent,
    required this.isImage,
  }) : super(key: key);

  @override
  State<FullScreenPreview> createState() => _FullScreenPreviewState();
}

class _FullScreenPreviewState extends State<FullScreenPreview> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Screen'),
      ),
      body: Center(
        child: SizedBox(
          width: (width > height) ? height : width,
          child: (widget.isImage)
              ? ImagePreview(mediaContent: widget.mediaContent)
              : VideoPreview(mediaContent: widget.mediaContent),
        ),
      ),
    );
  }
}
