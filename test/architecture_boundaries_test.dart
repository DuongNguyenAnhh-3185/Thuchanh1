import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('layer dependency boundaries', () {
    test('domain depends only on domain code and Dart core libraries', () {
      final violations = <String>[];
      for (final file in _dartFiles('lib/domain')) {
        final source = file.readAsStringSync();
        for (final uri in _importUris(source)) {
          final resolvedPath = _resolveImport(file, uri);
          if (uri.startsWith('package:') &&
              !uri.startsWith('package:lab_01/domain/')) {
            violations.add('${file.path}: external import $uri');
          } else if (resolvedPath != null &&
              !_isWithin(resolvedPath, Directory('lib/domain').absolute.path)) {
            violations.add('${file.path}: cross-layer import $uri');
          }
        }
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('presentation does not depend on data implementations', () {
      _expectNoImportsInto('lib/presentation', 'lib/data');
    });

    test('data does not depend on presentation', () {
      _expectNoImportsInto('lib/data', 'lib/presentation');
    });
  });
}

void _expectNoImportsInto(String sourceDirectory, String forbiddenDirectory) {
  final violations = <String>[];
  final forbiddenPath = Directory(forbiddenDirectory).absolute.path;

  for (final file in _dartFiles(sourceDirectory)) {
    for (final uri in _importUris(file.readAsStringSync())) {
      final resolvedPath = _resolveImport(file, uri);
      if (resolvedPath != null && _isWithin(resolvedPath, forbiddenPath)) {
        violations.add('${file.path}: cross-layer import $uri');
      }
      if (uri.startsWith('package:lab_01/')) {
        final packagePath = uri
            .replaceFirst('package:lab_01/', 'lib/')
            .replaceAll('/', Platform.pathSeparator);
        if (_isWithin(
          File(packagePath).absolute.path,
          forbiddenPath,
        )) {
          violations.add('${file.path}: cross-layer import $uri');
        }
      }
    }
  }

  expect(violations, isEmpty, reason: violations.join('\n'));
}

Iterable<File> _dartFiles(String directoryPath) {
  return Directory(directoryPath)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

Iterable<String> _importUris(String source) {
  return RegExp(
    r'''(?:import|export)\s+['"]([^'"]+)['"]''',
  ).allMatches(source).map((match) => match.group(1)!);
}

String? _resolveImport(File sourceFile, String uri) {
  if (uri.startsWith('dart:') || uri.startsWith('package:')) {
    return null;
  }
  return Uri.file(sourceFile.absolute.path).resolve(uri).toFilePath();
}

bool _isWithin(String path, String directory) {
  final normalizedPath = _normalizePath(path);
  final normalizedDirectory = _normalizePath(directory);
  return normalizedPath == normalizedDirectory ||
      normalizedPath.startsWith('$normalizedDirectory/');
}

String _normalizePath(String path) {
  final normalized = path.replaceAll(r'\', '/');
  return Platform.isWindows ? normalized.toLowerCase() : normalized;
}
