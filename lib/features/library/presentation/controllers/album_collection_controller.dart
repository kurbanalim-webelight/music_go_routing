import 'package:flutter/foundation.dart';

class AlbumCollectionController extends ChangeNotifier {
  AlbumCollectionController();

  final Set<String> _albumIds = {};

  List<String> get albumIds => List.unmodifiable(_albumIds);

  bool contains(String albumId) => _albumIds.contains(albumId);

  void toggle(String albumId) {
    if (!_albumIds.remove(albumId)) _albumIds.add(albumId);
    notifyListeners();
  }
}
