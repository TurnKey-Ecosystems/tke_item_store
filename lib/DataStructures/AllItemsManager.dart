part of tke_item_store;

/* Item changes made by this device are handled slightly differently than item
 * changes recieved form the cloud. */
enum ChangeSource { DEVICE, CLOUD }

// Manages all item instances, only touch this if you know what you are doing.
abstract class AllItemsManager {
  static const String ITEM_ID_DIVIDER = "-";

  // Item Instances
  static Map<String, SingleItemManager> _itemInstances = Map();

  // The itemIDs belonging to each itemType
  static Map<String, Set<String>> _itemIDsForEachItemType = {};

  // Gets the itemIDs belonging to the given itemType
  static Getter<ObservableList<ItemClassType>> getItemsForItemType<ItemClassType extends Item>(
      {required String itemType, required ItemClassType itemFromItemID(Value<String> itemID)}) {
    return Computed(
      () {
        ObservableList<ItemClassType> items = ObservableList();
        _itemIDsForEachItemType[itemType]?.forEach((String itemID) {
          items.add(itemFromItemID(itemID.v).g);
        });
        return items;
      },
      recomputeTriggers: [
        getOnItemOfTypeCreatedOrDestroyedEvent(itemType: itemType),
      ],
    );
  }

  // Return the instance of the requested item
  static SingleItemManager? getItemInstance(String itemID) {
    return _itemInstances[itemID];
  }

  // On item of type created or destroyed events
  static Map<String, Event> _onItemOfTypeCreatedOrDestroyedEvent = {};
  static Event getOnItemOfTypeCreatedOrDestroyedEvent({
    required String itemType,
  }) {
    // These events are lazy-loaded
    if (!_onItemOfTypeCreatedOrDestroyedEvent.containsKey(itemType)) {
      _onItemOfTypeCreatedOrDestroyedEvent[itemType] = Event();
    }
    return _onItemOfTypeCreatedOrDestroyedEvent[itemType]!;
  }

  // Load items from local fiels
  /*static void setupAllItemsManagerFromLocalFiles() {
    List<Map<String, dynamic>> itemJsons = [];
    List<String> itemFileNames = DiskController.getLocalFileNamesFromFileExtension(SingleItemManager._FILE_EXTENTION);
    F_UI.debugPrint(D_Convert.jsonEncode(itemFileNames));
    for (String itemFileName in itemFileNames) {
      itemJsons.add(
        D_Convert.jsonDecode(DiskController.readFileAsString(itemFileName)!),
      );
    }
    setupAllItemsManagerFromItemJsons(
      itemJsons: itemJsons,
    );
  }*/

  static List<String> Function({required String fileExtension})?
      _getLocalFileNamesFromFileExtension;
  static void Function({required String fileName})? _deleteFile;
  static String Function({required String fileName})? _readFileAsString;
  static void Function({required String fileName, required String contents})? _writeFileAsString;
  static void Function(Change change)? _commitChange;
  static void Function(List<Change> changes)? _commitChanges;

  // Reload items from local json files
  static void resetupAllItemsManagerFromItems({
    required Map<String, dynamic> itemJsonsByFileName,
  }) {
    // Clear all existing files
    _itemInstances = Map();
    List<String> oldItemFileNames =
        _getLocalFileNamesFromFileExtension!(fileExtension: SingleItemManager.FILE_EXTENTION);
    for (String fileName in oldItemFileNames) {
      _deleteFile!(fileName: fileName);
    }

    // Save all new files
    for (String fileName in itemJsonsByFileName.keys) {
      _writeFileAsString!(
        fileName: fileName,
        contents: D_Convert.jsonEncode(itemJsonsByFileName[fileName]),
      );
    }

    // Resetup the manager
    AllItemsManager.setupAllItemsManager(
      deviceID: _deviceID,
      requestNewItemIndex: _requestNewItemIndex!,
      getLocalFileNamesFromFileExtension: _getLocalFileNamesFromFileExtension!,
      deleteFile: _deleteFile!,
      readFileAsString: _readFileAsString!,
      writeFileAsString: _writeFileAsString!,
      commitChange: _commitChange!,
      commitChanges: _commitChanges!,
    );
  }

  // Load items from local json files
  static void setupAllItemsManager({
    required String deviceID,
    required int Function({required String itemType}) requestNewItemIndex,
    required List<String> Function({required String fileExtension})
        getLocalFileNamesFromFileExtension,
    required void Function({required String fileName}) deleteFile,
    required String Function({required String fileName}) readFileAsString,
    required void Function({required String fileName, required String contents}) writeFileAsString,
    required void Function(Change change) commitChange,
    required void Function(List<Change> changes) commitChanges,
  }) {
    _deviceID = deviceID;
    _requestNewItemIndex = requestNewItemIndex;
    _getLocalFileNamesFromFileExtension = getLocalFileNamesFromFileExtension;
    _deleteFile = deleteFile;
    _readFileAsString = readFileAsString;
    _writeFileAsString = writeFileAsString;
    _commitChange = commitChange;
    _commitChanges = commitChanges;
    List<String> itemFileNames =
        _getLocalFileNamesFromFileExtension!(fileExtension: SingleItemManager.FILE_EXTENTION);
    for (String itemFileName in itemFileNames) {
      // Load the item instance
      SingleItemManager itemInstance = SingleItemManager._fromUnknownJson(
        json: D_Convert.jsonDecode(_readFileAsString!(fileName: itemFileName)),
      );
      _itemInstances[itemInstance.itemID] = itemInstance;

      // Record the itemId under its item type
      if (_itemIDsForEachItemType[itemInstance.itemType] == null) {
        _itemIDsForEachItemType[itemInstance.itemType] = {};
      }
      _itemIDsForEachItemType[itemInstance.itemType]!.add(itemInstance.itemID);
    }
  }

  /** Applies any relevant changes from the list */
  static void applyChangesIfRelevant({
    required List<Change> changes,
  }) {
    // Sort the changes into different collections
    Map<String, ChangeItemCreation> itemCreationChanges = {};
    Map<String, ChangeItemDeletion> itemDeletionChanges = {};
    Map<String, List<ChangeAttributeInit>> attributeInitChanges = {};
    List<ChangeAttributeUpdate> attributeUpdateChanges = [];
    for (Change change in changes) {
      switch (change.changeType) {
        // Add to the item creation changes collection
        case ChangeType.ITEM_CREATION:
          itemCreationChanges[change.itemID] = change as ChangeItemCreation;
          break;

        // Add to the item deletion changes collection
        case ChangeType.ITEM_DELETION:
          itemDeletionChanges[change.itemID] = change as ChangeItemDeletion;
          break;

        // Add to the attribute init changes collection
        case ChangeType.ATTRIBUTE_INIT:
          if (!attributeInitChanges.containsKey(change.itemID)) {
            attributeInitChanges[change.itemID] = [];
          }
          attributeInitChanges[change.itemID]!.add(change as ChangeAttributeInit);
          break;

        // Add to the attribute init update collection
        case ChangeType.ATTRIBUTE_SET_VALUE:
        case ChangeType.ATTRIBUTE_ADD_VALUE:
        case ChangeType.ATTRIBUTE_REMOVE_VALUE:
          attributeUpdateChanges.add(change as ChangeAttributeUpdate);
          break;
      }
    }

    // Discard any item creations that are going to be shortly deleted
    for (String itemID in itemDeletionChanges.keys) {
      if (itemCreationChanges.containsKey(itemID)) {
        itemCreationChanges.remove(itemID);
      }
      if (attributeInitChanges.containsKey(itemID)) {
        attributeInitChanges.remove(itemID);
      }
    }

    // Apply any relevant attribute inits to existing items
    for (String itemID in attributeInitChanges.keys) {
      if (_itemInstances.containsKey(itemID)) {
        for (ChangeAttributeInit attributeInit in attributeInitChanges[itemID]!) {
          if (!_itemInstances[itemID]!._attributes.containsKey(attributeInit.attributeKey)) {
            // Create the new attribute
            InstanceOfAttribute newAttribute = InstanceOfAttribute._createNew(
              attributeInitDetails: attributeInit,
            );

            // Apply the attribtue to the session
            _itemInstances[itemID]!._attributes[attributeInit.attributeKey] = newAttribute;

            // Apply the attribute to the device
            if (attributeInit.changeApplicationDepth.index >= SyncDepth.DEVICE.index) {
              SingleItemManager._updateAttributeValueInDeviceStorage(attribute: newAttribute);
            }

            // Apply the attribute to the device
            if (attributeInit.changeApplicationDepth.index >= SyncDepth.CLOUD.index) {
              _commitChange!(attributeInit);
            }
          }
        }
      }
    }

    // Apply any relevant item creations
    for (ChangeItemCreation itemCreationChange in itemCreationChanges.values) {
      if (!_itemInstances.containsKey(itemCreationChange.itemID)) {
        // Create the item instance
        SingleItemManager itemInstance = SingleItemManager._createNewItem(
          itemCreationChange: itemCreationChange,
          attributeInitChanges: attributeInitChanges[itemCreationChange.itemID] ?? [],
        );

        // Add the item instance to list of item instances
        _itemInstances[itemInstance.itemID] = itemInstance;

        // The itemID lists for each itemType are lazy loaded
        if (!_itemIDsForEachItemType.containsKey(itemInstance.itemType)) {
          _itemIDsForEachItemType[itemInstance.itemType] = {};
        }

        // Add this item's itemID to the list of itemIDs for its itemType
        _itemIDsForEachItemType[itemInstance.itemType]!.add(itemInstance.itemID);

        // Trigger the item type creation event
        getOnItemOfTypeCreatedOrDestroyedEvent(itemType: itemCreationChange.itemType).trigger();
      }
    }

    // Apply any relevant attribute update chagnes
    for (ChangeAttributeUpdate change in attributeUpdateChanges) {
      if (_itemInstances.containsKey(change.itemID) &&
          _itemInstances[change.itemID]!._attributes.containsKey(change.attributeKey)) {
        _itemInstances[change.itemID]!
            ._attributes[change.attributeKey]!
            ._applyChangeIfRelevant(change);
      }
    }

    // Apply any relevant item deletions
    for (ChangeItemDeletion change in itemDeletionChanges.values) {
      for (final inst in _itemInstances.values) {
        print("This item \"${change.itemID}\" of \"${change.itemType}\" other items:");
        if (inst.itemType == change.itemType) {
          print(inst.itemID);
        }
        print("");
      }
      if (_itemInstances.containsKey(change.itemID)) {
        // Let listenners know that this item is being deleted
        print("About to call onDelete for \"${change.itemID}\" of \"${change.itemType}\"");
        _itemInstances[change.itemID]!.onDelete.trigger();

        // Commit this change
        if (change.changeApplicationDepth.index >= SyncDepth.CLOUD.index) {
          _commitChange!(change);
        }

        // Delete the local save file
        if (change.changeApplicationDepth.index >= SyncDepth.DEVICE.index) {
          _deleteFile!(fileName: SingleItemManager._getItemFileName(itemID: change.itemID));
        }

        // Remove the item instance from the list of item instances
        _itemInstances.remove(change.itemID);

        // Remove this item's itemID form the list of itemIDs of items of its type
        if (_itemIDsForEachItemType.containsKey(change.itemType)) {
          _itemIDsForEachItemType[change.itemType]!.remove(change.itemID);
        }

        // Trigger the item type deletion event
        getOnItemOfTypeCreatedOrDestroyedEvent(itemType: change.itemType).trigger();
      }
    }
  }

  /** Generate a new itemID */
  static String _deviceID = '';
  static int Function({
    required String itemType,
  })? _requestNewItemIndex = null;
  static String requestNewItemID({
    required String itemType,
  }) {
    int itemIndex = _requestNewItemIndex!(itemType: itemType);
    String itemID = itemType +
        ITEM_ID_DIVIDER +
        _deviceID +
        ITEM_ID_DIVIDER +
        itemIndex.toString().padLeft(10, "0");
    return itemID;
  }
}

/** Manages a local item instance */
class SingleItemManager {
  static const String FILE_EXTENTION = ".itm";
  static const String ITEM_TYPE_KEY = "itemType";
  static const String ITEM_ID_KEY = "itemID";
  static const String ATTRIBUTES_KEY = "attributes";

  // Item type
  String itemType;

  // Item ID
  String itemID;

  /** All the attributes in this item. */
  Map<String, InstanceOfAttribute> _attributes = Map();

  /** Retrieves an instance of an attribute */
  InstanceOfAttribute? getAttributeInstance({
    required String attributeKey,
  }) {
    return _attributes[attributeKey];
  }

  /** This will be triggered when this item is deleted */
  Event onDelete = Event();

  /** Creates a new item */
  SingleItemManager._createNewItem({
    required ChangeItemCreation itemCreationChange,
    required List<ChangeAttributeInit> attributeInitChanges,
  })  : this.itemType = itemCreationChange.itemType,
        this.itemID = itemCreationChange.itemID {
    // Apply changes at the session depth
    for (ChangeAttributeInit attributeInit in attributeInitChanges) {
      _attributes[attributeInit.attributeKey] = InstanceOfAttribute._createNew(
        attributeInitDetails: attributeInit,
      );
    }

    // Apply changes at the device depth
    if (itemCreationChange.changeApplicationDepth.index >= SyncDepth.CLOUD.index) {
      // Add the item creation change
      List<Change> changesToCommitToTheCloud = [itemCreationChange];

      // Add the cloud depth attribute inits
      for (ChangeAttributeInit attributeInit in attributeInitChanges) {
        if (attributeInit.changeApplicationDepth.index >= SyncDepth.DEVICE.index) {
          changesToCommitToTheCloud.add(attributeInit);
        }
      }

      // Commit the changes
      AllItemsManager._commitChanges!(changesToCommitToTheCloud);
    }

    // Apply changes at the device depth
    if (itemCreationChange.changeApplicationDepth.index >= SyncDepth.DEVICE.index) {
      // Generate a file name
      String fileName = _getItemFileName(itemID: itemID);

      // Convert the item instance into a json
      Map<String, dynamic> json = Map();
      json[ITEM_TYPE_KEY] = this.itemType;
      json[ITEM_ID_KEY] = this.itemID;

      // Add all the attributes to the json
      Map<String, dynamic> attributesAsJson = Map();
      for (ChangeAttributeInit attributeInit in attributeInitChanges) {
        if (attributeInit.changeApplicationDepth.index >= SyncDepth.DEVICE.index) {
          InstanceOfAttribute attribute = _attributes[attributeInit.attributeKey]!;
          attributesAsJson[attribute.attributeKey] = attribute.toJson();
        }
      }
      json[ATTRIBUTES_KEY] = attributesAsJson;

      // Save the new item instance locally
      AllItemsManager._writeFileAsString!(fileName: fileName, contents: D_Convert.jsonEncode(json));
    }
  }

  /** Loads a item instance from a json object */
  SingleItemManager._fromNewJson(dynamic json)
      : this.itemType = json[ITEM_TYPE_KEY],
        this.itemID = json[ITEM_ID_KEY] {
    // Parse the attributes from the json
    Map<String, dynamic> attributesFromJson = json[ATTRIBUTES_KEY];
    for (String attributeKey in attributesFromJson.keys) {
      dynamic attributeAsJson = attributesFromJson[attributeKey];
      _attributes[attributeKey] = InstanceOfAttribute._fromJson(
        itemID: itemID,
        attributeKey: attributeKey,
        attributeAsJson: attributeAsJson,
      );
    }
  }

  // Loads an item instance from a file.
  factory SingleItemManager._fromUnknownJson({required Map<String, dynamic> json}) {
    // If it json looks like the new format, then parse it
    if (json.containsKey(ATTRIBUTES_KEY)) {
      return SingleItemManager._fromNewJson(json);

      // Import old item files
    } else {
      // We'll create a new item.
      String itemType = json[ITEM_TYPE_KEY];
      String itemID = json[ITEM_ID_KEY];
      ChangeItemCreation itemCreationChange = ChangeItemCreation(
        itemType: itemType,
        itemID: itemID,
      );

      // Import all the old attributes
      List<ChangeAttributeInit> attributeInitChanges = [];
      List<ChangeAttributeUpdate> attributeUpdateChanges = [];
      for (String attributeKey in json.keys) {
        if (attributeKey != ITEM_TYPE_KEY && attributeKey != ITEM_ID_KEY) {
          // Read in the old value
          dynamic oldAttributeValue = json[attributeKey];

          // Attribute's of type Set need to be initialized and have all their values added back in.
          if (oldAttributeValue is Set || oldAttributeValue is List) {
            // Add the init change
            attributeInitChanges.add(
              ChangeAttributeInit.set(
                changeApplicationDepth: SyncDepth.CLOUD,
                itemID: itemID,
                attributeKey: attributeKey,
              ),
            );

            // Add all the elements back
            for (dynamic element in oldAttributeValue) {
              attributeUpdateChanges.add(
                ChangeAttributeAddValue(
                  changeApplicationDepth: SyncDepth.CLOUD,
                  itemID: itemID,
                  attributeKey: attributeKey,
                  value: element,
                ),
              );
            }

            // Create a property type attribute
          } else {
            attributeInitChanges.add(
              ChangeAttributeInit.property(
                changeApplicationDepth: SyncDepth.CLOUD,
                itemID: itemID,
                attributeKey: attributeKey,
                value: oldAttributeValue,
              ),
            );
          }
        }
      }

      // Create the new item
      SingleItemManager item = SingleItemManager._createNewItem(
        itemCreationChange: itemCreationChange,
        attributeInitChanges: attributeInitChanges,
      );

      // Add all Set Attribute elements back in
      item._applyChangesIfRelevant(attributeUpdateChanges);

      // Return the new item
      return item;
    }
  }

  /** */
  void _applyChangesIfRelevant(List<ChangeAttributeUpdate> attributeChanges) {
    for (ChangeAttributeUpdate attributeUpdate in attributeChanges) {
      if (_attributes.containsKey(attributeUpdate.attributeKey)) {
        bool changeWasRelevant =
            _attributes[attributeUpdate.attributeKey]!._applyChangeIfRelevant(attributeUpdate);
      }
    }
  }

  /** Updates the value of an attribute in device storage */
  static void _updateAttributeValueInDeviceStorage({required InstanceOfAttribute attribute}) {
    String itemFileName = _getItemFileName(itemID: attribute.itemID);

    // Read in the item file
    Map<String, dynamic> itemJson =
        D_Convert.jsonDecode(AllItemsManager._readFileAsString!(fileName: itemFileName));

    // Update the attributes value
    itemJson[ATTRIBUTES_KEY][attribute.attributeKey] = attribute.toJson();

    // Save the updated item json.
    AllItemsManager._writeFileAsString!(
        fileName: itemFileName, contents: D_Convert.jsonEncode(itemJson));
  }

  /** Generates the file name for the given item */
  static String _getItemFileName({required String itemID}) {
    return itemID + FILE_EXTENTION;
  }
}

/** These are the basic types of allowed attributes. */
enum AttributeType { PROPERTY, SET }

/** Manages an instance of an either a property or a set attribute. */
class InstanceOfAttribute {
  // The itemID of the item this attribute is associated with
  final String itemID;

  // The attributeKey of this attribute
  final String attributeKey;

  // On after change Event
  final Event onAfterChange = Event();

  /** We keep this attribute as a json map, and just modify the values in the json. */
  Map<String, dynamic> _attributeAsJson;

  /** This is the key to use for storing the last time this attribute was changed. */
  static const String _TIME_OF_LAST_CHANGE_JSON_KEY = "timeOfLastChangePosix";

  /** This attribute serializes to an object. This is the json key of this
   * attribute's value. */
  static const String _VALUE_JSON_KEY = "value";

  /** Retrieves this attribute as if it was a property attribute. */
  dynamic get valueAsProperty {
    return _attributeAsJson[_VALUE_JSON_KEY];
  }

  /** Checks if the change is relevant, and, if so, sets this attribute's value. */
  bool _setValueIfRelevant({
    required dynamic value,
    required int changeTimePosix,
  }) {
    bool wasRelevant = false;

    // Grab the current value for comparison
    dynamic currentValue = _attributeAsJson[_VALUE_JSON_KEY];
    int currentChangeTimePosix = _attributeAsJson[_TIME_OF_LAST_CHANGE_JSON_KEY];

    // If the new value is more recent and different, then it is relevant
    if (changeTimePosix > currentChangeTimePosix && value != currentValue) {
      _attributeAsJson[_VALUE_JSON_KEY] = value;
      _attributeAsJson[_TIME_OF_LAST_CHANGE_JSON_KEY] = changeTimePosix;
      wasRelevant = true;
    }

    // Let the caller know whether or not the change was relevant
    return wasRelevant;
  }

  /** This attribute serializes to an object. This is the json key of this
   * attribute's value. */
  static const String _REMOVED_VALUES_JSON_KEY = "removedValues";

  /** Get all the values in this attribute as if it was a Set. */
  Set<ExpectedType> getAllValuesAsSet<ExpectedType>() {
    return Set.from(_attributeAsJson[_VALUE_JSON_KEY].keys);
  }

  /** Checks if the change is relevant, and, if so, adds the value to this set. */
  bool _addValueIfRelevant({
    required dynamic value,
    required int changeTimePosix,
  }) {
    bool wasRelevant = false;

    // Grab the current value for comparison
    bool isInSet = _attributeAsJson[_VALUE_JSON_KEY][value] != null;
    int currentChangeTimePosix = (isInSet)
        ? _attributeAsJson[_VALUE_JSON_KEY][value]
        : _attributeAsJson[_REMOVED_VALUES_JSON_KEY][value] ?? 0;

    // If the new value is more recent, then we at least want to update the change time
    if (changeTimePosix > currentChangeTimePosix) {
      _attributeAsJson[_VALUE_JSON_KEY][value] = changeTimePosix;

      // The add was only relevant if it actually changed the list
      wasRelevant = !isInSet;

      // The value is back in the set now, so we can remove its deletion time
      if (_attributeAsJson[_REMOVED_VALUES_JSON_KEY].containsKey(value)) {
        _attributeAsJson[_REMOVED_VALUES_JSON_KEY].remove(value);
      }
    }

    // Let the caller know whether or not the change was relevant
    return wasRelevant;
  }

  /** Checks if the change is relevant, and, if so, removes the value from this set. */
  bool _removeValue({
    required dynamic value,
    required int changeTimePosix,
  }) {
    bool wasRelevant = false;

    // Grab the current value for comparison
    bool isInSet = _attributeAsJson[_VALUE_JSON_KEY][value] != null;
    int currentChangeTimePosix = (isInSet)
        ? _attributeAsJson[_VALUE_JSON_KEY][value]
        : _attributeAsJson[_REMOVED_VALUES_JSON_KEY][value] ?? 0;

    // If the new value is more recent, then we at least want to update the change time
    if (changeTimePosix > currentChangeTimePosix) {
      _attributeAsJson[_REMOVED_VALUES_JSON_KEY][value] = changeTimePosix;

      // The remove was only relevant if it actually changed the list
      wasRelevant = isInSet;

      // Remove the value from the set
      if (_attributeAsJson[_VALUE_JSON_KEY].containsKey(value)) {
        _attributeAsJson[_VALUE_JSON_KEY].remove(value);
      }
    }

    // Let the caller know whether or not the change was relevant
    return wasRelevant;
  }

  /** All children should override this */
  Map<String, dynamic> toJson() {
    return _attributeAsJson;
  }

  /** Sets up a new attibute based on a json. */
  InstanceOfAttribute._fromJson({
    required this.itemID,
    required this.attributeKey,
    required Map<String, dynamic> attributeAsJson,
  }) : _attributeAsJson = attributeAsJson;

  /** Sets up a new attibute based on a change. */
  InstanceOfAttribute._createNew({required ChangeAttributeInit attributeInitDetails})
      : this.itemID = attributeInitDetails.itemID,
        this.attributeKey = attributeInitDetails.attributeKey,
        this._attributeAsJson = Map() {
    // Different types of attributes need to be setup differently
    switch (attributeInitDetails.attributeType) {
      // Setup a set attribute
      case AttributeType.PROPERTY:
        _attributeAsJson[_VALUE_JSON_KEY] = attributeInitDetails.value;
        _attributeAsJson[_TIME_OF_LAST_CHANGE_JSON_KEY] = 0;
        break;

      // Setup a basic value attribute
      case AttributeType.SET:
        _attributeAsJson[_VALUE_JSON_KEY] = Map();
        _attributeAsJson[_REMOVED_VALUES_JSON_KEY] = Map();
        _attributeAsJson[_TIME_OF_LAST_CHANGE_JSON_KEY] = 0;
        break;
    }
  }

  /** Checks if the given change is relevant, and applies it. Returns whether or
   * not the change was relevant */
  bool _applyChangeIfRelevant(ChangeAttributeUpdate change) {
    bool wasRelevant = false;

    // Apply this change
    switch (change.changeType) {
      // Set value
      case ChangeType.ATTRIBUTE_SET_VALUE:
        wasRelevant = _setValueIfRelevant(
          value: change.value,
          changeTimePosix: change.changeTimePosix,
        );
        break;

      // Add to Set
      case ChangeType.ATTRIBUTE_ADD_VALUE:
        wasRelevant = _addValueIfRelevant(
          value: change.value,
          changeTimePosix: change.changeTimePosix,
        );
        break;

      // Remove from Set
      case ChangeType.ATTRIBUTE_REMOVE_VALUE:
        wasRelevant = _removeValue(
          value: change.value,
          changeTimePosix: change.changeTimePosix,
        );
        break;

      // Theoretically we shouldn't get any non-attribute update change types
      case ChangeType.ATTRIBUTE_INIT:
      case ChangeType.ITEM_CREATION:
      case ChangeType.ITEM_DELETION:
        throw ("InstanceOfAttribute.applyChangeIfRelevant() recieved an attribute of class \"ChangeAttributeUpdate\" but change type ${change.changeType}");
    }

    // Perform requested if-relevant actiosn
    if (wasRelevant) {
      // Save this change locally
      if (change.changeApplicationDepth.index >= SyncDepth.DEVICE.index) {
        SingleItemManager._updateAttributeValueInDeviceStorage(attribute: this);
      }

      // Commit this change
      if (change.changeApplicationDepth == SyncDepth.CLOUD) {
        AllItemsManager._commitChange!(change);
      }

      // Let listeners know that this attribute has been changed
      onAfterChange.trigger();
    }

    // Tell the caller whether or not this change was relevant.
    return wasRelevant;
  }
}
