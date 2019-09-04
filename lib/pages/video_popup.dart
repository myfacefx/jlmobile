import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPopupPage extends StatefulWidget {
  final String videoPath;
  final String animalName;
  VideoPopupPage({Key key, @required this.videoPath, @required this.animalName})
      : super(key: key);

  @override
  _VideoPopupPage createState() => _VideoPopupPage(videoPath, animalName);
}

class _VideoPopupPage extends State<VideoPopupPage> {
  VideoPlayerController _controller;
  String _videoPath;
  String _animalName;


  _VideoPopupPage(String videoPath, String animalName){
    _videoPath = videoPath;
    _animalName = animalName;
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(_videoPath)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _controller.play();
  }


    // use this when you want to get video from path on the device
    // void initState() {
    // super.initState();
    // var file = new File(_videoPath);
    // _controller = VideoPlayerController.file(file)
    //   ..initialize().then((_) {
    //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    //     setState(() {});
    //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text(_animalName),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: _controller.value.initialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

}
