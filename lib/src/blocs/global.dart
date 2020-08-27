import 'package:music_app/src/blocs/music_player.dart';
import 'package:music_app/src/blocs/permissions.dart';

class GlobalBloc {
  PermissionsBloc _permissionsBloc;
  ZMusicPlayerBloc _musicPlayerBloc;

  ZMusicPlayerBloc get musicPlayerBloc => _musicPlayerBloc;

  PermissionsBloc get permissionsBloc => _permissionsBloc;

  GlobalBloc() {
    _musicPlayerBloc = ZMusicPlayerBloc();
    _permissionsBloc = PermissionsBloc();
  }

  void dispose() {
    _musicPlayerBloc.dispose();
    _permissionsBloc.dispose();
  }
}
