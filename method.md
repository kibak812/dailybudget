# Method - Error Solutions Log

This document records errors encountered during development and their solutions.

---

## Google Play 16KB Page Size Error (2025-12-28)

### Error
Google Play Console rejects APK/AAB upload with error:
> "App does not support 16KB memory page size"

### Cause
- Android 15+ requires 16KB page size support
- Native libraries (`.so` files) must be compiled with 16KB alignment
- The `isar` package (3.1.0+1) was not compiled with 16KB support

### Solution
Migrate from `isar` to `isar_community` (maintained fork with 16KB support):

1. **Update pubspec.yaml**:
```yaml
# Before
dependencies:
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1

dev_dependencies:
  isar_generator: ^3.1.0+1

# After
dependencies:
  isar_community: ^3.3.0
  isar_community_flutter_libs: ^3.3.0

dev_dependencies:
  isar_community_generator: ^3.3.0
```

2. **Update all imports**:
```dart
// Before
import 'package:isar/isar.dart';

// After
import 'package:isar_community/isar.dart';
```

3. **Rebuild**:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build appbundle --release
```

4. **Verify 16KB alignment**:
```bash
zipalign -c -P 16 -v 4 app-release.apk
# Should output: "Verification successful"
```

### References
- [Isar 16KB Issue #1699](https://github.com/isar/isar/issues/1699)
- [isar_community on pub.dev](https://pub.dev/packages/isar_community)
- [Android 16KB Page Size Guide](https://developer.android.com/guide/practices/page-sizes)

---
