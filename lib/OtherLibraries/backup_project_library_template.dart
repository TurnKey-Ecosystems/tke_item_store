//library tke_flutter_core_v_3_0;

// Imports
import 'dart:async' as D_Async;
import 'dart:io' as D_IO;
import 'dart:convert' as D_Convert;
import 'dart:developer' as D_Dev;
import 'dart:math' as D_Math;
import 'dart:typed_data' as D_Data;
import 'dart:ui' as D_UI;
import 'package:flutter/material.dart' as F_UI;
import 'package:flutter/foundation.dart' as F_Foundation;
import 'package:flutter/services.dart' as F_Services;
import 'package:flutter/gestures.dart' as F_Gestures;
import 'package:path/path.dart' as Path;
import 'package:quiver/core.dart' as Quiver;
import 'package:quiver/iterables.dart' as Quiver;
import 'package:flutter_share/flutter_share.dart' as Sharer;
import 'package:flutter_mailer/flutter_mailer.dart' as Mailer;

// Managed by tke-cli DO NOT TOUCH
// tke-cli-begin-tag: "parts"
// tke-cli-end-tag: "parts"

// Global functions
void log(String message) {
  F_UI.debugPrint(message);
}
