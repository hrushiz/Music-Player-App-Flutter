import 'package:flutter/material.dart';
import 'package:music_app/src/blocs/global.dart';
import 'package:music_app/src/ui/home/home.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

/**
 * Z Music Player App
 */
class ZMusicPlayerApp extends StatelessWidget {
  final GlobalBloc _globalBloc = GlobalBloc();

  @override
  Widget build(BuildContext context) {
    return Provider<GlobalBloc>(
      builder: (BuildContext context) {
        _globalBloc.permissionsBloc.storagePermissionStatus$.listen(
          (data) {
            if (data == PermissionStatus.granted) {
              _globalBloc.musicPlayerBloc.fetchSongs().then(
                (_) {
                  _globalBloc.musicPlayerBloc.retrieveFavorites();
                },
              );
            }
          },
        );
        return _globalBloc;
      },
      dispose: (BuildContext context, GlobalBloc value) => value.dispose(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          sliderTheme: SliderThemeData(
            trackHeight: 1,
          ),
        ),
        home: SafeArea(
          child: StreamBuilder<PermissionStatus>(
            stream: _globalBloc.permissionsBloc.storagePermissionStatus$,
            builder: (BuildContext context,
                AsyncSnapshot<PermissionStatus> snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.white,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final PermissionStatus _status = snapshot.data;
              if (_status == PermissionStatus.denied) {
                _globalBloc.permissionsBloc.requestStoragePermission();
                return Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.white,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return MusicHomepage();
              }
            },
          ),
        ),
      ),
    );
  }
}
