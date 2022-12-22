part of tke_item_store;

// Acts a a control pannel for an item instance
abstract class Item {
  ///
  static const String _CONTAINED_IN_DELIMITER = ".";

  /// These are the attribute item sets that contain this item
  late final AttributeStringSet _containedIn = AttributeStringSet(
    attributeKey: "tfc_containedIn",
    itemManager: itemManager,
    itemClassInstance: this,
  );

  // The instnace of this item
  late final Getter<SingleItemManager> itemManager = Computed(
    () => AllItemsManager.getItemInstance(itemID.value)!,
    recomputeTriggers: [
      itemID.onAfterChange,
    ],
  );

  // Expose the itemID for getting
  final Value<String> _itemID;
  late final Getter<String> itemID = _itemID;

  /// Only use this if you know what you are doing.
  void setReference(String newItemID) {
    _itemID.value = newItemID;
  }

  // Expose the onDelete event for listeners
  late final Value<String> _oldItemID;
  final Event onDelete = Event();

  /// All dev defiend attribtues on this item
  final List<Attribute> _allDevDefinedAttributes = [];

  /// All dev defiend attribtues on this item
  List<Attribute> get allDevDefinedAttributes {
    return _allDevDefinedAttributes;
  }

  @deprecated
  List<Attribute> getAllAttributes() {
    return _allDevDefinedAttributes;
  }

  List<Attribute> _getAllAttributes() {
    List<Attribute> allAttributes = List.from(allDevDefinedAttributes);
    allAttributes.add(_containedIn);
    return allAttributes;
  }

  /**Creates a new item */
  Item.createNew({required String itemType})
      : this._itemID = _doFirstTimeSetUp(itemType: itemType) {
    /*// Create a list to collect changes in
    List<Change> changes = [];

    // Create the item creation change
    changes.add(
      ChangeItemCreation(
        changeApplicationDepth: SyncDepth.CLOUD,
        itemType: itemType,
        itemID: itemID.value,
      ),
    );

    // Create an attribute init change for each attribute
    for (Attribute attribute in _getAllAttributes()) {
      changes.add(
        attribute.getAttributeInitChange(itemID: itemID.value),
      );
    }

    // Create the new item isntance
    AllItemsManager.applyChangesIfRelevant(changes: changes);*/

    // Wire up the onDelete event
    attatchOnDeleteToItemManager();

    // Wire up the attributes
    //_connectAttributesToAttributeInstances();
  }

  // This allows some setup to happen before attributes an instantiated.
  static Value<String> _doFirstTimeSetUp({required String itemType}) {
    Value<String> itemID = AllItemsManager.requestNewItemID(itemType: itemType).v;
    AllItemsManager.applyChangesIfRelevant(changes: [
      ChangeItemCreation(
        itemType: itemType,
        itemID: itemID.value,
      ),
    ]);
    return itemID;
  }

  /** Creates a new item control pannel for the item with the given itemID. */
  Item.fromItemID(this._itemID) {
    attatchOnDeleteToItemManager();
    //_connectAttributesToAttributeInstances();
  }

  void attatchOnDeleteToItemManager() {
    // Respond to changes in the
    this._oldItemID = ''.v;
    this._oldItemID.value = itemID.value;
    itemManager.value.onDelete.addListener(onDelete.trigger);
    this.itemID.onAfterChange.addListener(() {
      // Stop listening to the old item instance
      AllItemsManager.getItemInstance(_oldItemID.value)?.onDelete.removeListener(onDelete.trigger);
      _oldItemID.value = itemID.value;

      // Start listening to changes in the new item instance
      itemManager.value.onDelete.addListener(onDelete.trigger);
    });
  }

  // Allows us to set the max syncDepth for an item.
  static Map<String, SyncDepth> _maxSyncDepthByItemType = {};
  static void setMaxSyncDepthForItemType({
    required String itemType,
    required SyncDepth maxSyncDepth,
  }) =>
      _maxSyncDepthByItemType[itemType] = maxSyncDepth;
  static SyncDepth getMaxSyncDepthForItemType(String itemType) =>
      _maxSyncDepthByItemType[itemType] ?? SyncDepth.CLOUD;

  /** Sets up all the attributes in this item */
  /*void _connectAttributesToAttributeInstances() {
    for (Attribute attribute in _getAllAttributes()) {
      attribute.connectToAttributeInstance(
        itemManager: _itemManager,
      );
    }
  }*/

  /** Permanently delete this item */
  void delete() {
    List<Change> changes = [];

    // Delete this item.
    print(
        "Deleting: \"${itemID.value}\" of \"${itemManager.value.itemType}\" at \"${Item.getMaxSyncDepthForItemType(itemManager.value.itemType)}\"");
    changes.add(
      ChangeItemDeletion(
        itemType: itemManager.value.itemType,
        itemID: itemID.value,
      ),
    );

    // Remove this item from all lists that contain it.
    for (String setAddress in _containedIn.allElements) {
      List<String> addressParts = setAddress.split(_CONTAINED_IN_DELIMITER);
      String containingItemID = addressParts[0];
      String containingSetKey = addressParts[1];
      changes.add(
        ChangeAttributeRemoveValue(
          itemID: containingItemID,
          attributeKey: containingSetKey,
          value: itemID.value,
          changeApplicationDepth: Item.getMaxSyncDepthForItemType(itemManager.value.itemType),
        ),
      );
    }

    // Apply all the deletion changes
    AllItemsManager.applyChangesIfRelevant(
      changes: changes,
    );
  }

  // Items are identified by their itemID
  @override
  int get hashCode => itemID.hashCode;

  // Items are identified by their itemID
  @override
  bool operator ==(dynamic other) {
    return other is Item && other.itemID == itemID;
  }
}
