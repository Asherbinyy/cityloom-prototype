import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  
  String? _currentAsset;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackSpeed = 1.0;
  bool _isScriptExpanded = false;
  
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _completeSub;

  // Getters
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get playbackSpeed => _playbackSpeed;
  bool get isScriptExpanded => _isScriptExpanded;
  String? get currentAsset => _currentAsset;

  AudioController() {
    _initStreams();
  }

  int _lastRenderedSecond = -1;
  int _lastRenderedMs = 0;

  void _initStreams() {
    _posSub = _player.onPositionChanged.listen((pos) {
      final sec = pos.inSeconds;
      final ms = pos.inMilliseconds;
      if (sec != _lastRenderedSecond || (ms - _lastRenderedMs).abs() >= 250) {
        _lastRenderedSecond = sec;
        _lastRenderedMs = ms;
        _position = pos;
        notifyListeners();
      }
    });

    _durSub = _player.onDurationChanged.listen((dur) {
      _duration = dur;
      notifyListeners();
    });

    _stateSub = _player.onPlayerStateChanged.listen((state) {
      _isPlaying = (state == PlayerState.playing);
      notifyListeners();
    });

    _completeSub = _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _position = Duration.zero;
      notifyListeners();
    });
  }

  Future<void> loadAndPlay(String assetPath) async {
    // If the path starts with 'assets/', remove it for audioplayers AssetSource
    final cleanPath = assetPath.startsWith('assets/')
        ? assetPath.substring('assets/'.length)
        : assetPath;

    if (_currentAsset == cleanPath && _isPlaying) {
      await pause();
      return;
    }

    if (_currentAsset != cleanPath) {
      await _player.stop();
      _currentAsset = cleanPath;
      _position = Duration.zero;
      await _player.setSource(AssetSource(cleanPath));
      await _player.setPlaybackRate(_playbackSpeed);
    }

    await _player.resume();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> togglePlay(String assetPath) async {
    final cleanPath = assetPath.startsWith('assets/')
        ? assetPath.substring('assets/'.length)
        : assetPath;

    if (_currentAsset == cleanPath) {
      if (_isPlaying) {
        await _player.pause();
        _isPlaying = false;
      } else {
        await _player.resume();
        _isPlaying = true;
      }
      notifyListeners();
    } else {
      await loadAndPlay(assetPath);
    }
  }

  Future<void> pause() async {
    if (_isPlaying) {
      await _player.pause();
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> toggleSpeed() async {
    if (_playbackSpeed == 1.0) {
      _playbackSpeed = 1.5;
    } else if (_playbackSpeed == 1.5) {
      _playbackSpeed = 2.0;
    } else if (_playbackSpeed == 2.0) {
      _playbackSpeed = 3.0;
    } else {
      _playbackSpeed = 1.0;
    }
    try {
      await _player.setPlaybackRate(_playbackSpeed);
    } catch (e) {
      debugPrint('Playback rate error: $e');
    }
    notifyListeners();
  }

  void toggleScript() {
    _isScriptExpanded = !_isScriptExpanded;
    notifyListeners();
  }

  void setScriptExpanded(bool expanded) {
    _isScriptExpanded = expanded;
    notifyListeners();
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _completeSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
