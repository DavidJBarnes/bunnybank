export 'platform_audio_base.dart';
import 'platform_audio_base.dart';

import 'platform_audio_stub.dart' if (dart.library.html) 'platform_audio_web.dart';

PlatformAudio createPlatformAudio() => createPlatformAudioImpl();
