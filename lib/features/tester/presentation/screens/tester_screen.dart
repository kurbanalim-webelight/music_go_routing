import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/features/library/presentation/screens/library_screen.dart';
import 'package:music_go_routing/features/tester/presentation/models/notification_delay.dart';
import 'package:music_go_routing/features/tester/presentation/models/test_route.dart';
import 'package:music_go_routing/features/tester/presentation/widgets/deep_link_test_card.dart';
import 'package:music_go_routing/features/tester/presentation/widgets/expected_result_card.dart';
import 'package:music_go_routing/features/tester/presentation/widgets/notification_test_card.dart';
import 'package:music_go_routing/features/tester/presentation/widgets/route_picker.dart';
import 'package:music_go_routing/features/tester/presentation/widgets/tester_section.dart';
import 'package:music_go_routing/services/deeplink/deep_link_service.dart';

class _Choice {
  const _Choice(this.value, this.label);

  final String value;
  final String label;
}

// Steps, top to bottom: choose a screen, choose its details, check what should happen,
// then trigger it with a notification or a deep link.
class TesterScreen extends StatefulWidget {
  const TesterScreen({super.key});

  @override
  State<TesterScreen> createState() => _TesterScreenState();
}

class _TesterScreenState extends State<TesterScreen> {
  late final Map<RouteParameter, List<_Choice>> _choices = {
    for (final parameter in RouteParameter.values) parameter: _choicesFor(parameter),
  };

  late final Map<RouteParameter, String> _values = {
    for (final parameter in RouteParameter.values) parameter: _choices[parameter]!.first.value,
  };

  TestRoute _route = testRouteGroups.first.routes.first;
  NotificationDelay _delay = NotificationDelay.threeSeconds;
  bool _isSending = false;

  String get _location => _route.locationWith(_values);

  RouteParameter? get _unknownParameter {
    for (final parameter in _route.parameters) {
      if (_values[parameter] == parameter.unknownValue) {
        return parameter;
      }
    }
    return null;
  }

  bool get _isErrorCase => _unknownParameter != null || testRouteGroups.last.routes.contains(_route);

  String get _outcome => _unknownParameter?.unknownOutcome ?? _route.outcome;

  List<_Choice> _choicesFor(RouteParameter parameter) {
    final knownChoices = switch (parameter) {
      RouteParameter.tab => [for (final tab in LibraryTab.values) _Choice(tab.name, tab.name)],
      RouteParameter.artistId => [
        for (final artist in catalogRepository.artists) _Choice(artist.id, '${artist.name} (${artist.id})'),
      ],
      RouteParameter.albumId => [
        for (final album in catalogRepository.albums) _Choice(album.id, '${album.title} (${album.id})'),
      ],
      RouteParameter.trackId => [
        for (final album in catalogRepository.albums)
          for (final track in catalogRepository.tracksOf(album.trackIds))
            _Choice(track.id, '${track.title} · ${album.title} (${track.id})'),
      ],
    };

    final unknownChoice = _Choice(parameter.unknownValue, '⚠ Unknown ${parameter.label.toLowerCase()} (error case)');
    return [...knownChoices, unknownChoice];
  }

  Future<void> _sendNotification() async {
    setState(() => _isSending = true);
    final messenger = ScaffoldMessenger.of(context);

    await localNotificationService.schedule(
      title: 'Test: ${_route.label}',
      body: _location,
      location: _location,
      delay: _delay.duration,
    );

    if (!mounted) {
      return;
    }
    setState(() => _isSending = false);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Notification arrives in ${_delay.label}. ${_delay.hint}')));
  }

  @override
  Widget build(BuildContext context) {
    final parameters = _route.parameters;
    var step = 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Tester')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          TesterSection(
            step: step++,
            title: 'Choose a screen',
            child: RoutePicker(selected: _route, onSelected: (route) => setState(() => _route = route)),
          ),
          if (parameters.isNotEmpty) ...[
            TesterSection(
              step: step++,
              title: 'Choose details',
              subtitle: 'Pick an "Unknown" option to test the error case.',
              child: Column(
                children: [
                  for (final parameter in parameters) ...[
                    DropdownButtonFormField<String>(
                      key: ValueKey(parameter),
                      initialValue: _values[parameter],
                      isExpanded: true,
                      decoration: InputDecoration(labelText: parameter.label),
                      items: [
                        for (final choice in _choices[parameter]!)
                          DropdownMenuItem(
                            value: choice.value,
                            child: Text(choice.label, overflow: TextOverflow.ellipsis),
                          ),
                      ],
                      onChanged: (value) => setState(() => _values[parameter] = value!),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          TesterSection(
            step: step++,
            title: 'Check what should happen',
            child: ExpectedResultCard(location: _location, outcome: _outcome, isErrorCase: _isErrorCase),
          ),
          const SizedBox(height: 28),
          TesterSection(
            step: step++,
            title: 'Test with a notification',
            child: NotificationTestCard(
              delay: _delay,
              isSending: _isSending,
              onDelayChanged: (delay) => setState(() => _delay = delay),
              onSend: _sendNotification,
            ),
          ),
          const SizedBox(height: 28),
          TesterSection(
            step: step++,
            title: 'Or test with a deep link',
            child: DeepLinkTestCard(link: DeepLinkService.linkFor(_location)),
          ),
        ],
      ),
    );
  }
}
