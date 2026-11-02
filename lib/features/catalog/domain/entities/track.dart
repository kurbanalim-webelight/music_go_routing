class Track {
  const Track({required this.id, required this.title, required this.albumId, required this.duration});

  final String id;
  final String title;
  final String albumId;
  final Duration duration;
}

String formatDuration(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
