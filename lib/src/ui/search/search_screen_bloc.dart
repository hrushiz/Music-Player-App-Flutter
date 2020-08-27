import 'package:music_app/src/models/serviceresponse.dart';
import 'package:rxdart/rxdart.dart';

class SearchScreenBloc {
  BehaviorSubject<List<Results>> _filteredSongs$;

  BehaviorSubject<List<Results>> get filteredSongs$ => _filteredSongs$;

  SearchScreenBloc() {
    _filteredSongs$ = BehaviorSubject<List<Results>>.seeded([]);
  }

  void updateFilteredSongs(String filter, List<Results> songs) {
    final _phrase = filter.replaceAll(" ", "").toLowerCase();
    List<Results> _filteredSongs = [];
    if (_phrase.length == 0) {
      _filteredSongs$.add(_filteredSongs);
      return;
    }
    for (Results song in songs) {
      String _songName = "";
      String _albumName = "";
      String _artistNames = "";

      if (song.trackName != null)
        _songName = song.trackName.replaceAll(" ", "").toLowerCase();

      if (song.collectionName != null)
        _albumName = song.collectionName.replaceAll(" ", "").toLowerCase();

      if (song.artistName != null)
        _artistNames = song.artistName
            .replaceAll(" ", "")
            .replaceAll(";", "")
            .toLowerCase();

      final _songString = _songName + _albumName + _artistNames;

      if (_songString.contains(_phrase)) {
        _filteredSongs.add(song);
      }
    }

    if (_filteredSongs.length == 0) {
      _filteredSongs$.add(null);
    }

    _filteredSongs$.add(_filteredSongs);
  }

  void dispose() {
    _filteredSongs$.close();
  }
}
