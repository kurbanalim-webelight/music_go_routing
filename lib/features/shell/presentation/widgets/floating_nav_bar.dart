import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/theme.dart';
import 'package:music_go_routing/app/widgets/glass_pill.dart';

class FloatingNavItem {
  const FloatingNavItem({required this.icon, required this.selectedIcon, required this.label});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({required this.items, required this.selectedIndex, required this.onSelected, super.key});

  final List<FloatingNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => GlassPill(
    child: Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          for (final (i, item) in items.indexed)
            Expanded(
              child: _NavButton(item: item, selected: i == selectedIndex, onTap: () => onSelected(i)),
            ),
        ],
      ),
    ),
  );
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final FloatingNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.marigold : AppColors.paper.withValues(alpha: 0.72);
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 58,
          decoration: BoxDecoration(
            color: selected ? AppColors.ink.withValues(alpha: 0.85) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? item.selectedIcon : item.icon, color: color, size: 24),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
