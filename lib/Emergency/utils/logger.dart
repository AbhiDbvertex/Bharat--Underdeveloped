String bwLoggerTag = 'Bharat-Works-Logger';
String logs = '[$bwLoggerTag] - Starting at ${DateTime.now()}';
// FirebaseAnalytics analytics = FirebaseAnalytics.instance;

Future<void> bwDebug(dynamic message, {String? tag}) async {
  String log = "\n[$bwLoggerTag] ${tag == null ? '' : '($tag)'}:- $message";
  print(log);
  logs += log;
}
