import 'package:logger/logger.dart';

export 'package:logger/logger.dart';

final _filter = ProductionFilter();

final Logger logger = Logger(
  filter: _filter,
  printer: SimplePrinter(),
  level: Level.info,
);

extension LoggerExt on Logger {
  static final Set<int> _loggedOnce = {};

  void logOnce(Level level, Object message) {
    final hashCode = message.hashCode;

    if (_loggedOnce.contains(hashCode)) {
      return;
    }

    log(level, message);
    _loggedOnce.add(hashCode);
  }

  void setFilterLevel(Level level) {
    _filter.level = level;
  }
}
