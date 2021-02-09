class AudioNote{
  final String path;
  int _duration;

  AudioNote({this.path, int duration}):assert(duration != null){
    _duration = duration??0;
  }

  String get duration {
    Duration _dur = Duration(milliseconds: _duration);
    return _dur.inMinutes.toString()+":"+(_dur.inSeconds%60<10?"0"+(_dur.inSeconds%60).toString():_dur.inSeconds%60).toString();
  }

}