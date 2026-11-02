import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/features/library/presentation/screens/library_screen.dart';
import 'package:music_go_routing/features/notification_tester/presentation/models/notification_route_option.dart';

class _Choice {
  const _Choice(this.value, this.label);

  final String value;
  final String label;
}

class NotificationTesterScreen extends StatefulWidget {
  const NotificationTesterScreen({super.key});

  @override
  State<NotificationTesterScreen> createState() => _NotificationTesterScreenState();
}

class _NotificationTesterScreenState extends State<NotificationTesterScreen> {
  static const Duration _delay = Duration(seconds: 3);

  late final Map<RouteParameter, List<_Choice>> _choices = {
    for (final parameter in RouteParameter.values) parameter: _choicesFor(parameter),
  };

  late final Map<RouteParameter, String> _values = {
    for (final parameter in RouteParameter.values) parameter: _choices[parameter]!.first.value,
  };

  NotificationRouteOption _option = notificationRouteOptions.first;
  bool _isSending = false;

  String get _location => _option.locationWith(_values);

  String get _outcome {
    for (final parameter in _option.parameters) {
      if (_values[parameter] == parameter.unknownValue) {
        return parameter.unknownOutcome;
      }
    }
    return _option.outcome;
  }

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

    final unknownChoice = _Choice(
      parameter.unknownValue,
      'Unknown ${parameter.label.toLowerCase()} (${parameter.unknownValue})',
    );
    return [...knownChoices, unknownChoice];
  }

  Future<void> _send() async {
    setState(() => _isSending = true);
    final messenger = ScaffoldMessenger.of(context);

    await localNotificationService.schedule(title: _option.label, body: _location, location: _location, delay: _delay);

    if (!mounted) {
      return;
    }
    setState(() => _isSending = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Arrives in ${_delay.inSeconds} seconds. Stay here, or close the app to test a cold start.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Notification tester')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          Text(
            'Pick where the notification should take you. It arrives ${_delay.inSeconds} seconds after you send it.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<NotificationRouteOption>(
            initialValue: _option,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Screen'),
            items: [
              for (final option in notificationRouteOptions) DropdownMenuItem(value: option, child: Text(option.label)),
            ],
            onChanged: (option) => setState(() => _option = option!),
          ),
          for (final parameter in _option.parameters) ...[
            const SizedBox(height: 14),
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
          ],
          const SizedBox(height: 24),
          _PreviewCard(location: _location, outcome: _outcome),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isSending ? null : _send,
            icon: const Icon(Icons.schedule_send_rounded),
            label: Text('Send in ${_delay.inSeconds} seconds'),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.location, required this.outcome});

  final String location;
  final String outcome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Opens', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          SelectableText(location, style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'monospace')),
          const SizedBox(height: 12),
          Text('Expected', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(outcome, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
