import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android app id, namespace and MainActivity package match', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    final namespace = RegExp(
      r'namespace\s*=\s*"([^"]+)"',
    ).firstMatch(gradle)?.group(1);
    final applicationId = RegExp(
      r'applicationId\s*=\s*"([^"]+)"',
    ).firstMatch(gradle)?.group(1);

    expect(namespace, isNotNull);
    expect(applicationId, isNotNull);
    expect(namespace, applicationId);
    expect(manifest, contains('android:name=".MainActivity"'));

    final appId = applicationId!;
    final activityPath =
        'android/app/src/main/kotlin/${appId.replaceAll('.', '/')}/MainActivity.kt';
    final activity = File(activityPath).readAsStringSync();
    final activityPackage = RegExp(
      r'^package\s+([A-Za-z0-9_.]+)',
      multiLine: true,
    ).firstMatch(activity)?.group(1);

    expect(activityPackage, appId);
    expect(
      File(
        'android/app/src/main/kotlin/com/example/voyger/MainActivity.kt',
      ).existsSync(),
      isFalse,
    );
  });
}
