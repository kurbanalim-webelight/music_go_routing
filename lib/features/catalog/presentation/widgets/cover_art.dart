import 'package:material_ui/material_ui.dart';

// Generated cover: the album colour as a gradient with the title's first letter.
// Shared element between the mini player and the full player.
const nowPlayingArtTag = 'now-playing-art';

// Hero flight: rebuild the cover at the in-flight size so the letter scales with the box,
// morphing from the mini player's circle (52) to the full player's rounded square (360).
Widget coverArtFlight(Color color, String label) => LayoutBuilder(
  builder: (context, box) {
    final size = box.maxWidth;
    final t = ((size - 52) / (360 - 52)).clamp(0.0, 1.0);
    return CoverArt(color: color, label: label, size: size, radius: size / 2 + (18 - size / 2) * t);
  },
);

class CoverArt extends StatelessWidget {
  const CoverArt({required this.color, required this.label, this.size = 56, this.radius = 8, super.key});

  final Color color;
  final String label;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(size * 0.09),
    alignment: Alignment.bottomLeft,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, Color.lerp(color, Colors.black, 0.55)!],
      ),
    ),
    child: Text(
      label.isEmpty ? '' : label.characters.first,
      style: TextStyle(
        fontSize: size * 0.42,
        height: 1,
        fontWeight: FontWeight.w900,
        color: Colors.white.withValues(alpha: 0.82),
      ),
    ),
  );
}
