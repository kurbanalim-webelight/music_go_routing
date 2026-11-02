import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/widgets/empty_state.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({required this.onGoHome, super.key});

  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmptyState(
        icon: Icons.explore_off_rounded,
        title: 'Page not found',
        message: 'This link points to a page that does not exist.',
        action: FilledButton(onPressed: onGoHome, child: const Text('Go home')),
      ),
    );
  }
}
