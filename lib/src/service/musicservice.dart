import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:music_app/src/models/serviceresponse.dart';

class AppleMusicStore {

  AppleMusicStore();

  static const BASE_URL = 'https://itunes.apple.com';
  static const _SONG_URL = "$BASE_URL/songs";
  static const _ARTIST_URL = "$BASE_URL/artists";
  static const _SEARCH_URL = "$BASE_URL/search";

  Future<dynamic> fetchJSON(String url) async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Future<dynamic> fetchResultsByQuery(String query) async {
    var completer = new Completer();

    final url = "$_SEARCH_URL?types=artists&term=$query";

    final json = await fetchJSON(url);
    final List<Results> songs = [];

    final songJSON = json['results'];
    if (songJSON != null) {
      songs.addAll((songJSON as List).map((a) => Results.fromJson(a)));
    }

    completer.complete(songs);
    return completer.future;
  }
}
