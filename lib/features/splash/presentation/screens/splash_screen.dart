import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/features/splash/presentation/controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.onSignedIn, required this.onSignedOut, super.key});

  final ValueChanged<String?> onSignedIn;
  final ValueChanged<String?> onSignedOut;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashController _controller = const SplashController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _controller.initialize();
    final launchLocation = await appController.completeStartup();
    if (!mounted) {
      return;
    }

    if (_controller.isSignedIn) {
      widget.onSignedIn(launchLocation);
    } else {
      widget.onSignedOut(launchLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.graphic_eq_rounded, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Music', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 32),
            const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
          ],
        ),
      ),
    );
  }
}
