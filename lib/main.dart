import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/app.dart';
import 'package:music_go_routing/app/di.dart';

void main() {
  runApp(MusicApp(router: appRouter));
  unawaited(appController.start());
}
