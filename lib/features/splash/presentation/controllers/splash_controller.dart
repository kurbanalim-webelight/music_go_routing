import 'package:music_go_routing/app/di.dart';

class SplashController {
  const SplashController();

  static const Duration _minimumDisplayTime = Duration(seconds: 3);

  bool get isSignedIn => authController.isSignedIn;

  Future<void> initialize() async {
    await Future.wait([Future<void>.delayed(_minimumDisplayTime), _runStartupTasks()]);
  }

  // Startup work goes here: restore the session, load remote config, warm caches.
  Future<void> _runStartupTasks() async {
    await authController.restoreSession();
  }
}
