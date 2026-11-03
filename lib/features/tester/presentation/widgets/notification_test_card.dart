import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/features/tester/presentation/models/notification_delay.dart';

class NotificationTestCard extends StatelessWidget {
  const NotificationTestCard({
    required this.delay,
    required this.isSending,
    required this.onDelayChanged,
    required this.onSend,
    super.key,
  });

  final NotificationDelay delay;
  final bool isSending;
  final ValueChanged<NotificationDelay> onDelayChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Arrives after', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<NotificationDelay>(
              showSelectedIcon: false,
              segments: [
                for (final option in NotificationDelay.values) ButtonSegment(value: option, label: Text(option.label)),
              ],
              selected: {delay},
              onSelectionChanged: (selection) => onDelayChanged(selection.single),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${delay.hint} Then tap the notification when it appears.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isSending ? null : onSend,
              icon: const Icon(Icons.notifications_active_outlined),
              label: Text('Send notification in ${delay.label}'),
            ),
          ],
        ),
      ),
    );
  }
}
