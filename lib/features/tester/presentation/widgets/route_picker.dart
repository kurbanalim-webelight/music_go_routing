import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/features/tester/presentation/models/test_route.dart';

// Every route visible at once, grouped by tab, so testers can scan instead of scrolling a dropdown.
class RoutePicker extends StatelessWidget {
  const RoutePicker({required this.selected, required this.onSelected, super.key});

  final TestRoute selected;
  final ValueChanged<TestRoute> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in testRouteGroups) ...[
          Text(group.title, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final route in group.routes)
                ChoiceChip(label: Text(route.label), selected: route == selected, onSelected: (_) => onSelected(route)),
            ],
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}
