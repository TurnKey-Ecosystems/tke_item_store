part of tke_item_store;

// Models an attribute instance
abstract class Attribute {
  final Getter<SingleItemManager> _itemManager;

  // The attribute instance that this Attribute models
  late final Getter<InstanceOfAttribute> attributeInstance = Computed(
    () {
      // Ensure that an instance of this attribute exists
      if (_itemManager.value.getAttributeInstance(attributeKey: attributeKey) == null) {
        AllItemsManager.applyChangesIfRelevant(changes: [
          getAttributeInitChange(itemID: _itemManager.value.itemID),
        ]);
      }
      return _itemManager.value.getAttributeInstance(attributeKey: attributeKey)!;
    },
    recomputeTriggers: [
      _itemManager.onAfterChange,
    ],
  );

  // We'll expose the on-after-change event of the attribute instance.
  late final Value<String> _oldItemID;
  final Event onAfterChange = Event();

  // This is mainly used for storing the attribute key while the attribute is being initialized
  final String attributeKey;

  // This is mainly used for storing the syncDepth while the attribute is being initialized
  final SyncDepth syncDepth;

  // Create a new control panel for an attribute instance
  Attribute({
    required this.attributeKey,
    required SyncDepth syncDepth,
    required Getter<SingleItemManager> itemManager,
    required Item itemClassInstance,
  })  : _itemManager = itemManager,
        this.syncDepth = (() {
          if (syncDepth.index > itemClassInstance.maxSyncDepth.index) {
            return itemClassInstance.maxSyncDepth;
          } else {
            return syncDepth;
          }
        }()) {
    // This is scrappy, but since it's associated with the calss it should be okay for now
    itemClassInstance._allDevDefinedAttributes.add(this);

    // Respond to changes in the item managers
    attributeInstance.value.onAfterChange.addListener(onAfterChange.trigger);
    _oldItemID = ''.v;
    _oldItemID.value = _itemManager.value.itemID;
    _itemManager.onAfterChange.addListener(() {
      // Stop listening to the old item instance
      AllItemsManager.getItemInstance(_oldItemID.value)
          ?.getAttributeInstance(attributeKey: attributeKey)
          ?.onAfterChange
          .removeListener(onAfterChange.trigger);
      _oldItemID.value = _itemManager.value.itemID;

      // Start listening to changes in the new item instance
      attributeInstance.value.onAfterChange.addListener(onAfterChange.trigger);

      // The item instance has changed so the attribute has changed.
      onAfterChange.trigger();
    });
  }

  /** Gets the attribute init change object for this attribute. */
  ChangeAttributeInit getAttributeInitChange({
    required String itemID,
  });

  // An attribute has a unique attributeKey within its assocaited item.
  @override
  int get hashCode => Quiver.hash2(_itemManager.value.itemID.hashCode, attributeKey.hashCode);

  // An attribute has a unique attributeKey within its assocaited item.
  @override
  bool operator ==(dynamic other) {
    return other is Attribute &&
        other._itemManager.value.itemID.hashCode == _itemManager.value.itemID.hashCode &&
        other.attributeKey.hashCode == attributeKey.hashCode;
  }
}
