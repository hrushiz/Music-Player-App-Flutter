import 'dart:async';
import 'dart:convert';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:music_app/src/models/album.dart';
import 'package:music_app/src/models/playback.dart';
import 'package:music_app/src/models/playerstate.dart';
import 'package:music_app/src/models/serviceresponse.dart';
import 'package:music_app/src/service/musicservice.dart';
import 'package:rxdart/rxdart.dart';

class ZMusicPlayerBloc {
  BehaviorSubject<List<Results>> _songs$;
  List<Results> songList;
  BehaviorSubject<List<Album>> _albums$;
  BehaviorSubject<MapEntry<PlayerState, Results>> _playerState$;
  BehaviorSubject<MapEntry<List<Results>, List<Results>>>
      _playlist$; //key is normal, value is shuffle
  BehaviorSubject<Duration> _position$;
  BehaviorSubject<List<Playback>> _playback$;
  BehaviorSubject<List<Results>> _favorites$;
  List<Results> favoriteSong;
  BehaviorSubject<bool> _isAudioSeeking$;
  MusicFinder _audioPlayer;
  Results _defaultSong;

  BehaviorSubject<List<Results>> get songs$ => _songs$;

  BehaviorSubject<MapEntry<PlayerState, Results>> get playerState$ =>
      _playerState$;

  BehaviorSubject<Duration> get position$ => _position$;

  BehaviorSubject<List<Playback>> get playback$ => _playback$;

  BehaviorSubject<List<Results>> get favorites$ => _favorites$;

  ZMusicPlayerBloc() {
    _initDefaultSong();
    _initStreams();
    _initAudioPlayer();
  }

  Future<void> fetchSongs() async {
    AppleMusicStore store = new AppleMusicStore();
    await store.fetchResultsByQuery("Jack Johanson").then(
      (data) {
        _songs$.add(data);
      },
    );
  }

  void playMusic(Results song) {
    _audioPlayer.play(song.previewUrl);
    updatePlayerState(PlayerState.playing, song);
  }

  void pauseMusic(Results song) {
    _audioPlayer.pause();
    updatePlayerState(PlayerState.paused, song);
  }

  void stopMusic() {
    _audioPlayer.stop();
  }

  void updatePlayerState(PlayerState state, Results song) {
    _playerState$.add(MapEntry(state, song));
  }

  void updatePosition(Duration duration) {
    _position$.add(duration);
  }

  void updatePlaylist(List<Results> normalPlaylist) {
    List<Results> _shufflePlaylist = []..addAll(normalPlaylist);
    _shufflePlaylist.shuffle();
    _playlist$.add(MapEntry(normalPlaylist, _shufflePlaylist));
  }

  void playNextSong() {
    if (_playerState$.value.key == PlayerState.stopped) {
      return;
    }
    final Results _currentSong = _playerState$.value.value;
    final bool _isShuffle = _playback$.value.contains(Playback.shuffle);
    final List<Results> _playlist =
        _isShuffle ? _playlist$.value.value : _playlist$.value.key;
    int _index = _playlist.indexOf(_currentSong);
    if (_index == _playlist.length - 1) {
      _index = 0;
    } else {
      _index++;
    }
    stopMusic();
    playMusic(_playlist[_index]);
  }

  void playPreviousSong() {
    if (_playerState$.value.key == PlayerState.stopped) {
      return;
    }
    final Results _currentSong = _playerState$.value.value;
    final bool _isShuffle = _playback$.value.contains(Playback.shuffle);
    final List<Results> _playlist =
        _isShuffle ? _playlist$.value.value : _playlist$.value.key;
    int _index = _playlist.indexOf(_currentSong);
    if (_index == 0) {
      _index = _playlist.length - 1;
    } else {
      _index--;
    }
    stopMusic();
    playMusic(_playlist[_index]);
  }

  void _playSameSong() {
    final Results _currentSong = _playerState$.value.value;
    stopMusic();
    playMusic(_currentSong);
  }

  void _onSongComplete() {
    final List<Playback> _playback = _playback$.value;
    if (_playback.contains(Playback.repeatSong)) {
      _playSameSong();
      return;
    }
    playNextSong();
  }

  void audioSeek(double seconds) {
    _audioPlayer.seek(seconds);
  }

  void invertSeekingState() {
    final _value = _isAudioSeeking$.value;
    _isAudioSeeking$.add(!_value);
  }

  void updatePlayback(Playback playback) {
    List<Playback> _value = playback$.value;
    if (playback == Playback.shuffle) {
      final List<Results> _normalPlaylist = _playlist$.value.key;
      updatePlaylist(_normalPlaylist);
    }
    _value.add(playback);
    _playback$.add(_value);
  }

  void removePlayback(Playback playback) {
    List<Playback> _value = playback$.value;
    _value.remove(playback);
    _playback$.add(_value);
  }

  Future<void> saveFavorites() async {}

  void retrieveFavorites() async {
    AppleMusicStore store = new AppleMusicStore();
    await store.fetchResultsByQuery("Jack Johanson").then(
      (data) {
        _favorites$.add(data);
      },
    );
  }

  String _encodeSongToJson(Results song) {
    final _songMap = songToMap(song);
    final data = json.encode(_songMap);
    return data;
  }

  Map<String, dynamic> songToMap(Results song) {
    Map<String, dynamic> data = {};

    data['wrapperType'] = song.wrapperType;
    data['kind'] = song.kind;
    data['artistId'] = song.artistId;
    data['collectionId'] = song.collectionId;
    data['trackId'] = song.trackId;
    data['artistName'] = song.artistName;
    data['collectionName'] = song.collectionName;
    data['trackName'] = song.trackName;
    data['collectionCensoredName'] = song.collectionCensoredName;
    data['trackCensoredName'] = song.trackCensoredName;
    data['artistViewUrl'] = song.artistViewUrl;
    data['collectionViewUrl'] = song.collectionViewUrl;
    data['trackViewUrl'] = song.trackViewUrl;
    data['previewUrl'] = song.previewUrl;
    data['artworkUrl30'] = song.artworkUrl30;
    data['artworkUrl60'] = song.artworkUrl60;
    data['artworkUrl100'] = song.artworkUrl100;
    data['collectionPrice'] = song.collectionPrice;
    data['trackPrice'] = song.trackPrice;
    data['releaseDate'] = song.releaseDate;
    data['collectionExplicitness'] = song.collectionExplicitness;
    data['trackExplicitness'] = song.trackExplicitness;
    data['discCount'] = song.discCount;
    data['discNumber'] = song.discNumber;
    data['trackCount'] = song.trackCount;
    data['trackNumber'] = song.trackNumber;
    data['trackTimeMillis'] = song.trackTimeMillis;
    data['country'] = song.country;
    data['currency'] = song.currency;
    data['primaryGenreName'] = song.primaryGenreName;
    data['isStreamable'] = song.isStreamable;
    data['collectionArtistName'] = song.collectionArtistName;
    return data;
  }

  void _initDefaultSong() {
    _defaultSong = new Results();
  }

  void _initStreams() {
    _isAudioSeeking$ = BehaviorSubject<bool>.seeded(false);
    _songs$ = BehaviorSubject<List<Results>>();
    _position$ = BehaviorSubject<Duration>();
    _playlist$ = BehaviorSubject<MapEntry<List<Results>, List<Results>>>();
    _playback$ = BehaviorSubject<List<Playback>>.seeded([]);
    _favorites$ = BehaviorSubject<List<Results>>.seeded([]);
    _playerState$ = BehaviorSubject<MapEntry<PlayerState, Results>>.seeded(
      MapEntry(
        PlayerState.stopped,
        _defaultSong,
      ),
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = MusicFinder();
    _audioPlayer.setPositionHandler(
      (Duration duration) {
        final bool _isAudioSeeking = _isAudioSeeking$.value;
        if (!_isAudioSeeking) {
          updatePosition(duration);
        }
      },
    );
    _audioPlayer.setCompletionHandler(
      () {
        _onSongComplete();
      },
    );
  }

  /*void startPlayer(String uri) async {
    String path = await flutterSound.startPlayer(uri);
    await flutterSound.setVolume(1.0);
    print('startPlayer: $path');

    try {
      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) async {
        if (e != null) {
          slider_current_position = e.currentPosition;
          max_duration = e.duration;

          final remaining = e.duration - e.currentPosition;

          DateTime date = DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt(),
              isUtc: true);

          DateTime endDate = DateTime.fromMillisecondsSinceEpoch(
              remaining.toInt(),
              isUtc: true);

          String startText = DateFormat('mm:ss', 'en_GB').format(date);
          String endText = DateFormat('mm:ss', 'en_GB').format(endDate);

          if (this.mounted) {
            this.setState(() {
              this._startText = startText;
              this._endText = endText;
              this.slider_current_position = slider_current_position;
              this.max_duration = max_duration;
            });
          }
        } else {
          slider_current_position = 0;

          if (_playerSubscription != null) {
            _playerSubscription.cancel();
            _playerSubscription = null;
          }
          this.setState(() {
            this._isPlaying = false;
            this._startText = '00:00';
            this._endText = '00:00';
          });
        }
      });
    } catch (err) {
      print('error: $err');
      this.setState(() {
        this._isPlaying = false;
      });
    }
  }

  _pausePlayer() async {
    String result = await flutterSound.pausePlayer();
    print('pausePlayer: $result');
    this.setState(() {
      this._isPlaying = false;
    });
  }

  _resumePlayer() async {
    String result = await flutterSound.resumePlayer();
    print('resumePlayer: $result');
    this.setState(() {
      this._isPlaying = true;
    });
  }

  _seekToPlayer(int milliSecs) async {
    int secs = Platform.isIOS ? milliSecs / 1000 : milliSecs;

    if (_playerSubscription == null) {
      return;
    }

    String result = await flutterSound.seekToPlayer(secs);
    print('seekToPlayer: $result');
  }*/

  void dispose() {
    stopMusic();
    _isAudioSeeking$.close();
    _songs$.close();
    _albums$.close();
    _playerState$.close();
    _playlist$.close();
    _position$.close();
    _playback$.close();
    _favorites$.close();
  }
}
