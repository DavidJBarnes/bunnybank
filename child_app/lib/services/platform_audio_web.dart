import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/services.dart';

import 'platform_audio_base.dart';

PlatformAudio createPlatformAudioImpl() {
  String? _blobUrl;
  bool _loaded = false;

  return PlatformAudio(
    load: (String path) async {
      if (_loaded) return;
      try {
        final data = await rootBundle.load(path);
        final blob = html.Blob([data.buffer.asUint8List()], 'audio/wav');
        _blobUrl = html.Url.createObjectUrlFromBlob(blob);
        _loaded = true;
      } catch (e) {
        _loaded = true;
      }
    },
    play: () async {
      if (_blobUrl == null) return;
      final el = html.AudioElement(_blobUrl!);
      el.load();
      try {
        await el.play();
      } catch (_) {}
    },
    dispose: () {
      if (_blobUrl != null) {
        html.Url.revokeObjectUrl(_blobUrl!);
        _blobUrl = null;
      }
      _loaded = false;
    },
  );
}
