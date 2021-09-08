library tke_item_store;

// Imports
import 'dart:async' as D_Async;
import 'dart:collection' as D_Collections;
import 'dart:io' as D_IO;
import 'dart:convert' as D_Convert;
import 'dart:developer' as D_Dev;
import 'dart:math' as D_Math;
import 'dart:typed_data' as D_Data;
import 'package:flutter/material.dart' as F_UI;
import 'package:quiver/core.dart' as Quiver;

// Managed by tke-cli DO NOT TOUCH
// tke-cli-begin-tag: "parts"
part './DataStructures/AllItemsManager.dart';
part './DataStructures/Attributes/Attribute.dart';
part './DataStructures/Attributes/AttributeItem.dart';
part './DataStructures/Attributes/AttributeItemSet.dart';
part './DataStructures/Attributes/AttributeProperty.dart';
part './DataStructures/Attributes/AttributeStringSet.dart';
part './DataStructures/Change.dart';
part './DataStructures/Item.dart';
part './DataStructures/SyncDepth.dart';
part './Utilities/BasicValueWrapper.dart';
part './Utilities/Event.dart';
part './Utilities/OnAfterChange.dart';
// tke-cli-end-tag: "parts"

// Global functions
void log(String message) {
  F_UI.debugPrint(message);
}
