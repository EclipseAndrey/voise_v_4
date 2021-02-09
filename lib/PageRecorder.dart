import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'dart:io' as io;
import 'dart:math';

// import 'package:audio_recorder/audio_recorder.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voise_v_4/Models/AudioNote.dart';


class PageRecorder extends StatefulWidget {
  @override
  _PageRecorderState createState() => _PageRecorderState();
}

class _PageRecorderState extends State<PageRecorder> {

  LocalFileSystem localFileSystem;
  // Recording _recording =  Recording();
  bool _isListening = false;

  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  bool playing = false;
  String pathPlaying = "";


  AudioPlayer audioPlayer = AudioPlayer();

  List<AudioNote> audioNoteList ;

  @override
  void initState() {
    audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        // playerState = PlayerState.stopped;
        // duration = Duration(seconds: 0);
        // position = Duration(seconds: 0);
      });
    });
    audioNoteList = [AudioNote(path:"/storage/emulated/0/cristal.m4a", duration: 20000)];
    localFileSystem  = LocalFileSystem();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children:  List.generate(audioNoteList.length, (index) => itemRecord(audioNoteList[index])),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 150,
              child: Center(
                child: playing?playPanel():buttonRecord(),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget itemRecord(AudioNote audioNote){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        width: MediaQuery.of(context).size.width*0.95,
        height: 80,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: ()async{
                        _play(audioNote.path);
                      },
                      child: Icon(pathPlaying == audioNote.path?Icons.stop_circle_outlined:Icons.play_circle_outline_rounded, color: Colors.blueAccent, size: 38,)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(audioNote.path),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(audioNote.duration)
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget buttonRecord(){
    return AvatarGlow(
      animate: _isListening,
      glowColor: Theme.of(context).primaryColor,
      endRadius: 75.0,
      duration: const Duration(milliseconds: 2000),
      repeatPauseDuration: const Duration(milliseconds: 100),
      repeat: true,
      child: FloatingActionButton(
        onPressed: (){
          listen2();

        },
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
    );
  }
  Widget playPanel(){
    return FloatingActionButton(
      onPressed: (){
        _play(pathPlaying);

      },
      child: Icon(Icons.stop_circle_outlined),
    );
  }


  listen2()async{

    if(!_isListening){
      await _init();
      // try {

        await _recorder.start();
        var recording = await _recorder.current(channel: 0);
        setState(() {
          _current = recording;
        });

        const tick = const Duration(milliseconds: 50);
        new Timer.periodic(tick, (Timer t) async {
          if (_currentStatus == RecordingStatus.Stopped) {
            t.cancel();
            _isListening = false;
            setState(() {  });
            print(_current.path);


          }

          var current = await _recorder.current(channel: 0);
          // print(current.status);
          setState(() {
            _current = current;
            _currentStatus = _current.status;
          });
        });
        _isListening = true;
        setState(() {  });
      // } catch (e) {
      //   print(e);
      //   _isListening = false;
      //   setState(() {  });
      // }


    }else{
      await _recorder.pause();
      var result = await _recorder.stop();
      print("Stop recording: ${result.path}");
      print("Stop recording: ${result.duration}");
      File file = localFileSystem.file(result.path);
      print("File length: ${await file.length()}");
      setState(() {
        _current = result;
        _currentStatus = _current.status;
      });
      audioNoteList.add(AudioNote(path: _current.path, duration: (_current.duration.inMilliseconds)??0));
      setState(() {

      });


    }




  }

  // listen() async {
  //   if (!_isListening) {
  //     TextEditingController _controller = TextEditingController();
  //     try {
  //       if (await AudioRecorder.hasPermissions) {
  //         if (_controller.text != null && _controller.text != "") {
  //           String path = _controller.text;
  //           if (!_controller.text.contains('/')) {
  //             io.Directory appDocDirectory =
  //             await getApplicationDocumentsDirectory();
  //             path = appDocDirectory.path + '/' + _controller.text;
  //           }
  //           print("Start recording: $path");
  //           await AudioRecorder.start(
  //               path: path, audioOutputFormat: AudioOutputFormat.WAV);
  //         } else {
  //           await AudioRecorder.start();
  //         }
  //         bool isRecording = await AudioRecorder.isRecording;
  //         setState(() {
  //
  //           _recording = new Recording(duration: new Duration(), path: "");
  //           _isListening = isRecording;
  //         });
  //       } else {
  //         print('нет разрешения на микрофон');
  //       }
  //     } catch (e) {
  //       print(e);
  //     }
  //   }else{
  //     var recording = await AudioRecorder.stop();
  //     print("Stop recording: ${recording.path}");
  //     bool isRecording = await AudioRecorder.isRecording;
  //     File file = localFileSystem.file(recording.path);
  //     print("  File length: ${await file.length()}");
  //     setState(() {
  //       _recording = recording;
  //       _isListening = isRecording;
  //     });
  //     print(recording.path);
  //     audioNoteList.add(AudioNote(path: recording.path, duration: recording.duration.inMilliseconds));
  //     setState(() {
  //
  //     });
  //   }
  // }


  _play(String path)async{

    if(playing){
      if(pathPlaying == path){
        int result = await audioPlayer.stop();
        print("Stop "+result.toString());
        playing = false;
        pathPlaying = "";
      }else{
        int result = await audioPlayer.stop();
        print("Stop "+result.toString());
        int resultStart = await audioPlayer.play(path, isLocal: true);
        print("Start "+resultStart.toString());
        pathPlaying = path;
      }
    }else{
      playing = true;
      int resultStart = await audioPlayer.play(path, isLocal: true);
      print("Start "+resultStart.toString());
      pathPlaying = path;
    }
    setState(() {});



  }


  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        io.Directory appDocDirectory;
//        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.AAC);

        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      } else {

        print('permission err');
      }
    } catch (e) {
      print(e);
    }
  }

}
