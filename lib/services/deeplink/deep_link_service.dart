import 'package:app_links/app_links.dart';

class DeepLinkService {
  DeepLinkService();

  static const String _scheme = 'musicgo';
  static const String _host = 'share';

  final AppLinks _appLinks = AppLinks();

  Uri? _initialLink;

  Future<String?> initialLocation() async {
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink == null) {
      return null;
    }

    _initialLink = initialLink;
    return _locationFrom(initialLink);
  }

  Stream<String> get incomingLocations {
    return _appLinks.uriLinkStream.where(_isNewLink).map(_locationFrom).where((location) => location != null).cast();
  }

  // The stream replays the launch link once; initialLocation() already returned it.
  bool _isNewLink(Uri link) {
    if (link != _initialLink) {
      return true;
    }

    _initialLink = null;
    return false;
  }

  String? _locationFrom(Uri link) {
    final isAppLink = link.scheme == _scheme && link.host == _host;
    if (!isAppLink) {
      return null;
    }

    final query = link.query.isEmpty ? null : link.query;
    return Uri(path: link.path, query: query).toString();
  }
}
