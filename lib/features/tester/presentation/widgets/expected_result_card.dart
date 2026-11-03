import 'package:material_ui/material_ui.dart';

// What the tester should see after tapping the notification or link.
// Error cases are tinted so they are not mistaken for a bug.
class ExpectedResultCard extends StatelessWidget {
  const ExpectedResultCard({required this.location, required this.outcome, required this.isErrorCase, super.key});

  final String location;
  final String outcome;
  final bool isErrorCase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final background = isErrorCase ? colors.errorContainer : colors.surfaceContainer;
    final foreground = isErrorCase ? colors.onErrorContainer : colors.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isErrorCase ? Icons.report_outlined : Icons.check_circle_outline_rounded,
                size: 20,
                color: foreground,
              ),
              const SizedBox(width: 8),
              Text(
                isErrorCase ? 'Expected (error case)' : 'Expected result',
                style: theme.textTheme.labelLarge?.copyWith(color: foreground),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(outcome, style: theme.textTheme.bodyLarge?.copyWith(color: foreground)),
          const SizedBox(height: 12),
          SelectableText(
            location,
            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace', color: foreground),
          ),
        ],
      ),
    );
  }
}
