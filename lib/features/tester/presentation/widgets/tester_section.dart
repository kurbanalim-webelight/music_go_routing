import 'package:material_ui/material_ui.dart';

// A numbered step: "1  Choose a screen", with its content underneath.
class TesterSection extends StatelessWidget {
  const TesterSection({required this.step, required this.title, required this.child, this.subtitle, super.key});

  final int step;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: theme.colorScheme.primary,
              child: Text('$step', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimary)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
