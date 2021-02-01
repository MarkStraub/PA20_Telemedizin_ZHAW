import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hartslag/enum/data_request_type.dart';
import 'package:hartslag/services/data_request.dart';
import 'package:http/http.dart';
import 'package:video_player/video_player.dart';

// https://pub.dev/packages/video_player
// https://flutter.dev/docs/cookbook/plugins/play-video
// https://stackoverflow.com/questions/50818770/passing-data-to-a-stateful-widget
class ResultScreen extends StatefulWidget {
  final String videoId;
  const ResultScreen({Key key, @required this.videoId}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  Future<Response> _initializeHeartRateFuture;
  final ValueNotifier<Duration> _position = new ValueNotifier<Duration>(new Duration(seconds: 0));
  String _duration;

  @override
  void initState() {
    if (this.widget.videoId != null) {
      // Create an store the VideoPlayerController. The VideoPlayerController
      // offers several different constructors to play videos from assets, files,
      // or the internet.
      this._controller = VideoPlayerController.network('https://dublin.zhaw.ch/~strauma8/pa-sw-result.mp4');
      // this._controller = VideoPlayerController.network('http://10.0.2.2:8000/face/result/${this.widget.videoId}.mp4');
      this._initializeVideoPlayerFuture = this._controller.initialize();
      this._controller.addListener(() {
        this._position.value = this._controller.value.position;
      });
      this._controller.setLooping(true);

      // HeartRate
      this._initializeHeartRateFuture = DataRequest.getHeartRate(DataRequestType.face, this.widget.videoId);
    }
    super.initState();
  }

  @override
  void dispose() {
    this._controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Resultate'),
      ),
      body: this.widget.videoId != null ? this._buildContainer() : this._buildNoVideo(),
      floatingActionButton: this.widget.videoId != null ? this._pulseFloatincActionButton() : null,
    );
  }

  Container _buildNoVideo() {
    return new Container(
      child: new Padding(
        padding: EdgeInsets.all(10.0),
        child: new Center(
          child: new Text(
            'Es wurde noch kein Video zur Berechnung hochgeladen oder das Video ist schon älter als 2 Stunden.',
            style: TextStyle(
              fontSize: 23.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Container _buildContainer() {
    return new Container(
      // color: Theme.of(context).backgroundColor,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          new Container(
            child: this._heartRatePlayer(),
          ),
          this._buildProgress(),
          this._showHeartRate(),
        ],
      ),
    );
  }

  // https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html
  Container _buildProgress() {
    return new Container(
      child: new ValueListenableBuilder(
        valueListenable: this._position,
        builder: (BuildContext context, Duration position, Widget child) {
          // This builder will only get called when the _progress
          // is updated.
          var progressIndicator = this._controller.value.duration != null ? 1.0 / this._controller.value.duration.inSeconds * position.inSeconds : 0.0;

          // Set the duration time once the video has been loaded
          if (this._duration == null && this._controller.value.duration != null) {
            this._duration = [this._controller.value.duration.inHours, this._controller.value.duration.inMinutes, this._controller.value.duration.inSeconds]
                .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
                .join(':');
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              // https://api.flutter.dev/flutter/material/LinearProgressIndicator-class.html
              new LinearProgressIndicator(
                value: progressIndicator,
                minHeight: 7,
              ),
              new Align(
                alignment: Alignment.centerRight,
                child: new Padding(
                  padding: new EdgeInsets.only(right: 5.0),
                  child: new Text(
                    '${position.toString().split('.')[0]} / ${this._duration ?? "00:00:00"}',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  FutureBuilder _heartRatePlayer() {
    return new FutureBuilder(
      future: this._initializeVideoPlayerFuture,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the VideoPlayerController has finished initialization, use
          // the data it provides to limit the aspect ratio of the VideoPlayer.
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            // Use the VideoPlayer widget to display the video.
            child: VideoPlayer(_controller),
          );
        } else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  dynamic _pulseFloatincActionButton() {
    return new FloatingActionButton(
      onPressed: () {
        setState(() {
          this._controller.value.isPlaying ? this._controller.pause() : this._controller.play();
        });
      },
      child: new Icon(
        this._controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      ),
    );
  }

  FutureBuilder _showHeartRate() {
    return new FutureBuilder(
      future: this._initializeHeartRateFuture,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          String heartRate = 'No Heart Rate found';
          if (snapshot.data.statusCode == 200) {
            Map body = json.decode(snapshot.data.body);
            if (body.containsKey('heartRate')) {
              heartRate = body['heartRate'].toString();
            }
          }
          return new Container(
            child: new Padding(
              padding: EdgeInsets.only(top: 30),
              child: new Center(
                child: new Text(
                  heartRate,
                  style: TextStyle(fontSize: 80.0),
                ),
              ),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
