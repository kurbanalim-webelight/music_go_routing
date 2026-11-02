import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:music_go_routing/app/theme.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(title: 'Music', debugShowCheckedModeBanner: false, theme: AppTheme.dark, routerConfig: router);
}
