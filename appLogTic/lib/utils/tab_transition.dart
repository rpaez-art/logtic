import 'package:flutter/foundation.dart';

/// Direction of the tab transition for ShellRoute animations.
///
/// - `-1` = sliding right → going to a lower index
/// -  `0` = no slide (fade only)
/// -  `1` = sliding left  → going to a higher index
final tabDirection = ValueNotifier<int>(0);
