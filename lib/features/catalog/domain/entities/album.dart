import 'package:flutter/painting.dart';

class Album {
  const Album({
    required this.id,
    required this.title,
    required this.artistId,
    required this.year,
    required this.color,
    required this.trackIds,
  });

  final String id;
  final String title;
  final String artistId;
  final int year;
  final Color color;
  final List<String> trackIds;
}
