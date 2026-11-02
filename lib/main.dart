import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/app.dart';
import 'package:music_go_routing/app/router/app_router.dart';

// Create the router once, outside build, so hot reload and rebuilds keep navigation state.
final _router = createRouter();

void main() => runApp(MusicApp(router: _router));
