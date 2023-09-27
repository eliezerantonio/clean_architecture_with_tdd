part of 'http.dart';

void _printLogs(
  Map<String, dynamic> logs,
  StackTrace? stackTrace,
) {
  if (Platform.environment.containsKey('FLUTTER_TEST') &&
      logs.containsKey('exception')) {
    print(const JsonEncoder.withIndent('  ').convert(logs));
    print(stackTrace);
  }
  if (kDebugMode) {
    log(
      '''
🔥
--------------------------------
${const JsonEncoder.withIndent('  ').convert(logs)}
--------------------------------
🔥
''',
      stackTrace: stackTrace,
    );
  }
}
