import 'platform_audio_base.dart';

PlatformAudio createPlatformAudioImpl() {
  return PlatformAudio(
    load: (String path) async {},
    play: () async {},
    dispose: () {},
  );
}
