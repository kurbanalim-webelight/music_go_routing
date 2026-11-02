import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:music_go_routing/features/catalog/domain/entities/album.dart';
import 'package:music_go_routing/features/catalog/domain/entities/artist.dart';
import 'package:music_go_routing/features/catalog/domain/entities/track.dart';
import 'package:music_go_routing/features/catalog/domain/repositories/catalog_repository.dart';

// Holds what is playing. The mini player and the player screen both read from here.
// Simulated playback: a timer advances the position. Swap for just_audio when real audio is needed.
class MusicController extends ChangeNotifier {
  MusicController(this._catalogRepository);

  static const Duration _tickInterval = Duration(seconds: 1);
  static const Duration _restartThreshold = Duration(seconds: 3);

  final CatalogRepository _catalogRepository;

  List<Track> _queue = const [];
  int _index = 0;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  Timer? _ticker;

  Track? get currentTrack => _queue.isEmpty ? null : _queue[_index];

  Album? get currentAlbum {
    final track = currentTrack;
    return track == null ? null : _catalogRepository.album(track.albumId);
  }

  Artist? get currentArtist {
    final album = currentAlbum;
    return album == null ? null : _catalogRepository.artist(album.artistId);
  }

  bool get hasCurrentTrack => currentTrack != null;
  Duration get position => _position;
  bool get isPlaying => _isPlaying;
  bool get hasPrevious => _index > 0;
  bool get hasNext => _index < _queue.length - 1;

  double get progress {
    final total = currentTrack?.duration.inMilliseconds ?? 0;
    if (total == 0) {
      return 0;
    }
    return _position.inMilliseconds / total;
  }

  // Plays the track's album from that track. Returns false when the track is not in the catalog.
  bool playTrack(String trackId) {
    final track = _catalogRepository.track(trackId);
    if (track == null) {
      return false;
    }

    if (currentTrack?.id == track.id) {
      return true;
    }

    final album = _catalogRepository.album(track.albumId)!;
    final albumTracks = _catalogRepository.tracksOf(album.trackIds);
    playTracks(albumTracks, startAt: albumTracks.indexOf(track));
    return true;
  }

  void playTracks(List<Track> tracks, {int startAt = 0}) {
    if (tracks.isEmpty) {
      return;
    }

    _queue = List.unmodifiable(tracks);
    _index = startAt.clamp(0, tracks.length - 1);
    _position = Duration.zero;
    _isPlaying = true;
    _startTicker();
    notifyListeners();
  }

  void toggle() {
    if (!hasCurrentTrack) {
      return;
    }

    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startTicker();
    } else {
      _stopTicker();
    }
    notifyListeners();
  }

  void next() {
    if (!hasNext) {
      return;
    }

    _index++;
    _position = Duration.zero;
    notifyListeners();
  }

  void previous() {
    final shouldRestartTrack = _position > _restartThreshold || !hasPrevious;
    if (!shouldRestartTrack) {
      _index--;
    }

    _position = Duration.zero;
    notifyListeners();
  }

  void seek(double fraction) {
    final total = currentTrack?.duration ?? Duration.zero;
    _position = total * fraction.clamp(0, 1);
    notifyListeners();
  }

  void stop() {
    _stopTicker();
    _queue = const [];
    _index = 0;
    _position = Duration.zero;
    _isPlaying = false;
    notifyListeners();
  }

  void _tick(Timer _) {
    final total = currentTrack?.duration ?? Duration.zero;
    _position += _tickInterval;

    if (_position >= total) {
      _onTrackFinished(total);
    }
    notifyListeners();
  }

  void _onTrackFinished(Duration total) {
    if (hasNext) {
      _index++;
      _position = Duration.zero;
      return;
    }

    _position = total;
    _isPlaying = false;
    _stopTicker();
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(_tickInterval, _tick);
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
