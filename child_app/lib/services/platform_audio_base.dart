class PlatformAudio {
  final Future<void> Function(String path) load;
  final Future<void> Function() play;
  final void Function() dispose;

  PlatformAudio({
    required this.load,
    required this.play,
    required this.dispose,
  });
}
