// How long after "Send" the notification arrives. Each hint tells the tester which
// app state the delay gives them time to set up.
enum NotificationDelay {
  threeSeconds(Duration(seconds: 3), '3 s', 'Stay in the app to test it while it is open.'),
  fiveSeconds(Duration(seconds: 5), '5 s', 'Go to the home screen to test the app in the background.'),
  tenSeconds(Duration(seconds: 10), '10 s', 'Swipe the app away from recent apps to test a closed app.'),
  oneMinute(Duration(minutes: 1), '1 min', 'Lock the phone, or close the app without rushing.');

  const NotificationDelay(this.duration, this.label, this.hint);

  final Duration duration;
  final String label;
  final String hint;
}
