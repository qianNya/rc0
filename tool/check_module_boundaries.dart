#!/usr/bin/env dart
// Module boundary smoke check for rc0 monorepo packages.
//
// Fails when kernel packages import app feature paths.

import 'dart:io';

final _kernelRoots = [
  'packages/rc0_core/lib',
  'packages/rc0_media/lib',
  'packages/rc0_network/lib',
  'packages/rc0_ui/lib',
];

final _forbiddenImportPatterns = [
  RegExp(r"import\s+'\.+/features/"),
  RegExp(r'import\s+"\.+/features/'),
  RegExp(r"import\s+'package:rc0/.+/features/"),
];

void main() {
  var violations = 0;
  for (final root in _kernelRoots) {
    final dir = Directory(root);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final content = entity.readAsStringSync();
      for (final pattern in _forbiddenImportPatterns) {
        if (pattern.hasMatch(content)) {
          stderr.writeln('Boundary violation: ${entity.path}');
          violations++;
          break;
        }
      }
    }
  }
  if (violations > 0) {
    stderr.writeln('$violations kernel boundary violation(s).');
    exit(1);
  }
  stdout.writeln('Module boundary check passed.');
}
