import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class DeepLinkTestCard extends StatelessWidget {
  const DeepLinkTestCard({required this.link, super.key});

  final String link;

  String get _simulatorCommand => 'xcrun simctl openurl booted "$link"';
  String get _adbCommand => 'adb shell am start -a android.intent.action.VIEW -d "$link"';

  Future<void> _copy(BuildContext context, String text, String message) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // Goes out to the OS and back in, so it tests the real deep link path, not in-app navigation.
  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    if (!opened) {
      messenger.showSnackBar(const SnackBar(content: Text('The phone could not open this link.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(link, style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace')),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _copy(context, link, 'Link copied'),
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Copy link'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _open(context),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Open link'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('"Open link" tests the app while it is open.', style: mutedStyle),
                const SizedBox(height: 4),
                Text(
                  'To test a closed app on iPhone: copy the link, swipe the app away, '
                  'then paste the link into Safari\'s address bar and tap Go.',
                  style: mutedStyle,
                ),
              ],
            ),
          ),
          ExpansionTile(
            title: const Text('Commands for a computer'),
            subtitle: const Text('iOS Simulator and Android (adb)'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              _CommandRow(
                title: 'iOS Simulator',
                command: _simulatorCommand,
                onCopy: () => _copy(context, _simulatorCommand, 'Simulator command copied'),
              ),
              const SizedBox(height: 12),
              _CommandRow(
                title: 'Android (adb)',
                command: _adbCommand,
                onCopy: () => _copy(context, _adbCommand, 'adb command copied'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommandRow extends StatelessWidget {
  const _CommandRow({required this.title, required this.command, required this.onCopy});

  final String title;
  final String command;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              SelectableText(command, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
            ],
          ),
        ),
        IconButton(tooltip: 'Copy $title command', onPressed: onCopy, icon: const Icon(Icons.copy_rounded)),
      ],
    );
  }
}
