import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:music_go_routing/features/catalog/domain/entities/track.dart';

// Simulated playback: a timer advances position. Swap for just_audio when real audio is needed.
class PlayerController extends ChangeNotifier {
  PlayerController();

  List<Track> _queue = const [];
  int _index = 0;
  Duration _position = Duration.zero;
  bool _playing = false;
  Timer? _ticker;

  Track? get current => _queue.isEmpty ? null : _queue[_index];
  List<Track> get queue => _queue;
  Duration get position => _position;
  bool get isPlaying => _playing;
  bool get hasPrevious => _index > 0;
  bool get hasNext => _index < _queue.length - 1;
  double get progress {
    final total = current?.duration.inMilliseconds ?? 0;
    return total == 0 ? 0 : _position.inMilliseconds / total;
  }

  void play(List<Track> tracks, {int startAt = 0}) {
    if (tracks.isEmpty) return;
    _queue = List.unmodifiable(tracks);
    _index = startAt.clamp(0, tracks.length - 1);
    _position = Duration.zero;
    _playing = true;
    _startTicker();
    notifyListeners();
  }

  void toggle() {
    if (current == null) return;
    _playing = !_playing;
    _playing ? _startTicker() : _stopTicker();
    notifyListeners();
  }

  void next() {
    if (!hasNext) return;
    _index++;
    _position = Duration.zero;
    notifyListeners();
  }

  void previous() {
    if (_position > const Duration(seconds: 3) || !hasPrevious) {
      _position = Duration.zero;
    } else {
      _index--;
      _position = Duration.zero;
    }
    notifyListeners();
  }

  void stop() {
    _stopTicker();
    _queue = const [];
    _index = 0;
    _position = Duration.zero;
    _playing = false;
    notifyListeners();
  }

  void seek(double fraction) {
    final total = current?.duration ?? Duration.zero;
    _position = total * fraction.clamp(0, 1);
    notifyListeners();
  }

  void _tick(Timer _) {
    final total = current?.duration ?? Duration.zero;
    _position += const Duration(seconds: 1);
    if (_position >= total) {
      if (hasNext) {
        _index++;
        _position = Duration.zero;
      } else {
        _position = total;
        _playing = false;
        _stopTicker();
      }
    }
    notifyListeners();
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
