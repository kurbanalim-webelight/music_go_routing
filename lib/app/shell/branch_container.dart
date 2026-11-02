import 'package:material_ui/material_ui.dart';

// Replaces StatefulShellRoute.indexedStack's instant swap with a Material fade-through:
// the new tab fades in and settles from 96% scale. Inactive tabs stay alive (their stacks
// are kept) but are offstage: not painted, not hit-tested, tickers paused, hidden from semantics.
class BranchContainer extends StatefulWidget {
  const BranchContainer({required this.currentIndex, required this.children, super.key});

  final int currentIndex;
  final List<Widget> children;

  @override
  State<BranchContainer> createState() => _BranchContainerState();
}

class _BranchContainerState extends State<BranchContainer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: 1,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.1, 1, curve: Curves.easeOut),
  );
  late final Animation<double> _scale = Tween(
    begin: 0.96,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void didUpdateWidget(BranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex == widget.currentIndex) return;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    reduceMotion ? _controller.value = 1 : _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      for (final (i, navigator) in widget.children.indexed)
        if (i == widget.currentIndex)
          FadeTransition(
            opacity: _fade,
            child: ScaleTransition(scale: _scale, child: navigator),
          )
        else
          Offstage(child: TickerMode(enabled: false, child: navigator)),
    ],
  );
}
