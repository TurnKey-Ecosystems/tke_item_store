part of tke_item_store;

// Models an attribute instance
abstract class Attribute {
  // The attribute instance that this Attribute models
  InstanceOfAttribute? attributeInstance;


  // We'll expose the on-after-change event of the attribute instance.
  Event get onAfterChange {
    return attributeInstance!.onAfterChange;
  }


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
    required SingleItemManager itemManager,
  }) {
    // Ensure that an instance of this attribute exists
    if (itemManager.getAttributeInstance(attributeKey: attributeKey) == null) {
      AllItemsManager.applyChangesIfRelevant(
        changes: [
          getAttributeInitChange(itemID: itemManager.itemID),
        ]
      );
    }

    // Connect thist attribute to its isnstance
    this.attributeInstance = itemManager.getAttributeInstance(attributeKey: attributeKey)!;
  }


  /** Gets the attribute init change object for this attribute. */
  ChangeAttributeInit getAttributeInitChange({
    required String itemID,
  });


  // An attribute has a unique attributeKey within its assocaited item.
  @override
  int get hashCode => Quiver.hash2(attributeInstance!.itemID.hashCode, attributeKey.hashCode);

  // An attribute has a unique attributeKey within its assocaited item.
  @override
  bool operator ==(dynamic other) {
    return other is Attribute &&
        other.attributeInstance!.itemID.hashCode == attributeInstance!.itemID.hashCode &&
        other.attributeKey.hashCode == attributeKey.hashCode;
  }
}
