part of tke_flutter_core_v_3_0;

// The current legal change types
enum ChangeType {
  ITEM_CREATION,
  ITEM_DELETION,
  ATTRIBUTE_INIT,
  ATTRIBUTE_SET_VALUE,
  ATTRIBUTE_ADD_VALUE,
  ATTRIBUTE_REMOVE_VALUE,
}


// Describes a change made to items
abstract class Change {
  // The change details for the specifc type of change
  //late final Map<String, dynamic> _changeDetails;


  // Versioning
  static const int _CURRENT_API_VERSION = 1;
  static const String _API_VERSION_KEY = "apiVersion";
  final int apiVersion;


  // The type of change
  static const String _CHANGE_TYPE_KEY = "changeTypeIndex";
  final ChangeType changeType;
  

  // The sync depth of this change
  static const String _CHANGE_APPLICATION_DEPTH_KEY = "syncDepth";
  SyncDepth changeApplicationDepth;


  // The time, in milliseconds since epoch, this change was made
  static const String _CHANGE_TIME_POSIX_KEY = "changeTimePosix";
  final int changeTimePosix;
  
  // The itemID of the item that was changed
  final String itemID;
  

  /** Create a new change object */
  Change._({
    required this.changeType,
    required this.changeApplicationDepth,
    required this.itemID,
  })
    : this.apiVersion = _CURRENT_API_VERSION,
      this.changeTimePosix = DateTime.now().millisecondsSinceEpoch;

  /** Creates a change object fron a json */
  Change._fromJson(dynamic json)
    : this.apiVersion = json[_API_VERSION_KEY],
      this.changeType =
        ChangeType.values[json[_CHANGE_TYPE_KEY]],
      this.changeApplicationDepth =
        SyncDepth.values[json[_CHANGE_APPLICATION_DEPTH_KEY]],
      this.itemID = json[SingleItemManager.ITEM_ID_KEY],
      this.changeTimePosix = json[_CHANGE_TIME_POSIX_KEY];

  /** Covnerts this change log to a json */
  @F_UI.mustCallSuper
  Map<String, dynamic> toJson() {
    return {
      _API_VERSION_KEY: apiVersion,
      _CHANGE_TYPE_KEY: changeType.index,
      _CHANGE_APPLICATION_DEPTH_KEY: changeApplicationDepth.index,
      SingleItemManager.ITEM_ID_KEY: itemID,
      _CHANGE_TIME_POSIX_KEY: changeTimePosix,
    };
  }
  

  /** Load a change object from a json as the correct dart class.  */
  static Change fromJson(dynamic json) {
    ChangeType changeType = ChangeType.values[json[_CHANGE_TYPE_KEY]];
    switch(changeType) {
      case ChangeType.ITEM_CREATION:
        return ChangeItemCreation.fromJson(json);
      case ChangeType.ITEM_DELETION:
        return ChangeItemDeletion.fromJson(json);
      case ChangeType.ATTRIBUTE_INIT:
        return ChangeAttributeInit.fromJson(json);
      case ChangeType.ATTRIBUTE_SET_VALUE:
        return ChangeAttributeSetValue.fromJson(json);
      case ChangeType.ATTRIBUTE_ADD_VALUE:
        return ChangeAttributeAddValue.fromJson(json);
      case ChangeType.ATTRIBUTE_REMOVE_VALUE:
        return ChangeAttributeRemoveValue.fromJson(json);
    }
  }

  /** Get the class type corresponding to the change type.  */
  static Type changeClassFromChangeType(ChangeType changeType) {
    switch(changeType) {
      case ChangeType.ITEM_CREATION:
        return ChangeItemCreation;
      case ChangeType.ITEM_DELETION:
        return ChangeItemDeletion;
      case ChangeType.ATTRIBUTE_INIT:
        return ChangeAttributeInit;
      case ChangeType.ATTRIBUTE_SET_VALUE:
        return ChangeAttributeSetValue;
      case ChangeType.ATTRIBUTE_ADD_VALUE:
        return ChangeAttributeAddValue;
      case ChangeType.ATTRIBUTE_REMOVE_VALUE:
        return ChangeAttributeRemoveValue;
    }
  }
}



/** Item creation and deletion change types */
abstract class ChangeItemExistance extends Change {
  // The itemType of the item that was changed
  final String itemType;

  /** Creates a new item existance change. */
  ChangeItemExistance({
    required ChangeType changeType,
    required SyncDepth changeApplicationDepth,
    required this.itemType,
    required String itemID,
  })
    : super._(
      changeType: changeType,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
    );

  /** Loads a item existance change from a json. */
  ChangeItemExistance.fromJson(dynamic json)
    : this.itemType = json[SingleItemManager.ITEM_TYPE_KEY],
      super._fromJson(json);
  
  /** Converts an Item existance change to a json. */
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json[SingleItemManager.ITEM_TYPE_KEY] = itemType;
    return json;
  }
}

/** Item creation change type */
class ChangeItemCreation extends ChangeItemExistance {
  /** Creates a new item creation change object. */
  ChangeItemCreation({
    required String itemType,
    required String itemID,
    required SyncDepth changeApplicationDepth,
  })
    : super(
      changeType: ChangeType.ITEM_CREATION,
      changeApplicationDepth: changeApplicationDepth,
      itemType: itemType,
      itemID: itemID,
    );

  /** Loads an item creation change from a json. */
  ChangeItemCreation.fromJson(dynamic json) : super.fromJson(json);
}

/** Item deletion change type */
class ChangeItemDeletion extends ChangeItemExistance {
  /** Creates a new item deletion change object. */
  ChangeItemDeletion({
    required String itemType,
    required String itemID,
    required SyncDepth changeApplicationDepth,
  })
    : super(
      changeType: ChangeType.ITEM_DELETION,
      changeApplicationDepth: changeApplicationDepth,
      itemType: itemType,
      itemID: itemID,
    );

  /** Loads an item deletion change from a json. */
  ChangeItemDeletion.fromJson(dynamic json) : super.fromJson(json);
}



/** Attribute change types */
abstract class AttributeChange extends Change {
  // The type of the attribute that is being changed
  static const String _ATTRIBUTE_TYPE_KEY = "attributeType";
  final AttributeType attributeType;

  // The attributeKey of the attribute that was changed
  static const String _ATTRIBUTE_KEY_KEY = "attributeKey";
  final String attributeKey;

  // A generic value related to the type of change
  static const String _VALUE_KEY = "value";
  final dynamic value;
  

  /** Creates a new attribute change. */
  AttributeChange({
    required ChangeType changeType,
    required SyncDepth changeApplicationDepth,
    required String itemID,
    required this.attributeType,
    required this.attributeKey,
    required this.value,
  })
    : super._(
      changeType: changeType,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
    );

  /** Loads an atribute change from a json. */
  AttributeChange.fromJson(dynamic json)
    : this.attributeType = AttributeType.values[json[_ATTRIBUTE_TYPE_KEY]],
      this.attributeKey = json[_ATTRIBUTE_KEY_KEY],
      this.value = json[_VALUE_KEY],
      super._fromJson(json);
  
  /** Converts an Item existance change to a json. */
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json[_ATTRIBUTE_TYPE_KEY] = attributeType.index;
    json[_ATTRIBUTE_KEY_KEY] = attributeKey;
    json[_VALUE_KEY] = value;
    return json;
  }
}

/** Attribute-init change type */
class ChangeAttributeInit extends AttributeChange {
  /** Creates an attribute-init change for a property type attribute */
  ChangeAttributeInit.property({
    required SyncDepth changeApplicationDepth,
    required String itemID,
    required String attributeKey,
    required dynamic value,
  }) : super(
      changeType: ChangeType.ATTRIBUTE_INIT,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
      attributeType: AttributeType.PROPERTY,
      attributeKey: attributeKey,
      value: value,
    );

  /** Creates an attribute-init change for a set type attribute */
  ChangeAttributeInit.set({
    required SyncDepth changeApplicationDepth,
    required String itemID,
    required String attributeKey,
  }) : super(
      changeType: ChangeType.ATTRIBUTE_INIT,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
      attributeType: AttributeType.SET,
      attributeKey: attributeKey,
      value: [],
    );

  /** Loads an atribute-init change from a json. */
  ChangeAttributeInit.fromJson(dynamic json) : super.fromJson(json);
}



/** Attribute update types */
abstract class ChangeAttributeUpdate extends AttributeChange {
  /** Creates a new attribute update change. */
  ChangeAttributeUpdate({
    required ChangeType changeType,
    required SyncDepth changeApplicationDepth,
    required String itemID,
    required AttributeType attributeType,
    required String attributeKey,
    required dynamic value,
  })
    : super(
      changeType: changeType,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
      attributeType: attributeType,
      attributeKey: attributeKey,
      value: value,
    );

  /** Loads an atribute update change from a json. */
  ChangeAttributeUpdate.fromJson(dynamic json) : super.fromJson(json);
}

/** Attribute set value change type */
class ChangeAttributeSetValue extends ChangeAttributeUpdate {
  /** Creates a set value change object */
  ChangeAttributeSetValue({
    required SyncDepth changeApplicationDepth,
    required String itemID,
    required String attributeKey,
    required dynamic value,
  }) : super(
      changeType: ChangeType.ATTRIBUTE_SET_VALUE,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
      attributeType: AttributeType.PROPERTY,
      attributeKey: attributeKey,
      value: value,
    );

  /** Loads a set value change from a json. */
  ChangeAttributeSetValue.fromJson(dynamic json) : super.fromJson(json);
}

/** Attribute add value change type */
class ChangeAttributeAddValue extends ChangeAttributeUpdate {
  /** Creates an add value change object */
  ChangeAttributeAddValue({
    required SyncDepth changeApplicationDepth,
    required String itemID,
    required String attributeKey,
    required dynamic value,
  }) : super(
      changeType: ChangeType.ATTRIBUTE_ADD_VALUE,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
      attributeType: AttributeType.SET,
      attributeKey: attributeKey,
      value: value,
    );

  /** Loads an add value change from a json. */
  ChangeAttributeAddValue.fromJson(dynamic json) : super.fromJson(json);
}

/** Attribute remove value change type */
class ChangeAttributeRemoveValue extends ChangeAttributeUpdate {
  /** Creates a remove value change object */
  ChangeAttributeRemoveValue({
    required SyncDepth changeApplicationDepth,
    required String itemID,
    required String attributeKey,
    required dynamic value,
  }) : super(
      changeType: ChangeType.ATTRIBUTE_REMOVE_VALUE,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
      attributeType: AttributeType.SET,
      attributeKey: attributeKey,
      value: value,
    );

  /** Loads a remove value change from a json. */
  ChangeAttributeRemoveValue.fromJson(dynamic json) : super.fromJson(json);
}
