part of tke_item_store;

// Models an attribute instance
abstract class Attribute {
  late final Getter<SingleItemManager> _itemManager;

  // The attribute instance that this Attribute models
  late final Getter<InstanceOfAttribute> attributeInstance = Computed(
    () {
      // Ensure that an instance of this attribute exists
      if (_itemManager.value.getAttributeInstance(attributeKey: attributeKey) ==
          null) {
        AllItemsManager.applyChangesIfRelevant(changes: [
          getAttributeInitChange(itemID: _itemManager.value.itemID),
        ]);
      }
      return _itemManager.value
          .getAttributeInstance(attributeKey: attributeKey)!;
    },
    recomputeTriggers: [
      _itemManager.onAfterChange,
    ],
  );

  // We'll expose the on-after-change event of the attribute instance.
  late final Value<String> _oldItemID;
  late final Event onAfterChange = Event();

  // This is mainly used for storing the attribute key while the attribute is being initialized
  final String attributeKey;

  // This is mainly used for storing the syncDepth while the attribute is being initialized
  final SyncDepth syncDepth;

  // Create a new control panel for an attribute instance
  Attribute({
    required this.attributeKey,
    required this.syncDepth,
  });

  /** This should only be called by Item */
  void connectToAttributeInstance({
    required Getter<SingleItemManager> itemManager,
  }) {
    // Setup the item manager
    this._itemManager = itemManager;

    // Respond to changes in the item managers
    attributeInstance.value.onAfterChange.addListener(onAfterChange.trigger);
    _oldItemID = ''.v;
    _oldItemID.value = _itemManager.value.itemID;
    _itemManager.onAfterChange.addListener(() {
      print('_itemManager.onAfterChange triggered!');
      // Stop listening to the old item instance
      AllItemsManager.getItemInstance(_oldItemID.value)
          ?.getAttributeInstance(attributeKey: attributeKey)
          ?.onAfterChange
          .removeListener(onAfterChange.trigger);
      _oldItemID.value = _itemManager.value.itemID;

      // Start listening to changes in the new item instance
      attributeInstance.value.onAfterChange.addListener(onAfterChange.trigger);
    });
  }

  /** Gets the attribute init change object for this attribute. */
  ChangeAttributeInit getAttributeInitChange({
    required String itemID,
  });

  // An attribute has a unique attributeKey within its assocaited item.
  @override
  int get hashCode =>
      Quiver.hash2(_itemManager.value.itemID.hashCode, attributeKey.hashCode);

  // An attribute has a unique attributeKey within its assocaited item.
  @override
  bool operator ==(dynamic other) {
    return other is Attribute &&
        other._itemManager.value.itemID.hashCode ==
            _itemManager.value.itemID.hashCode &&
        other.attributeKey.hashCode == attributeKey.hashCode;
  }
}
