part of tke_item_store;


// Acts a a control pannel for an item instance
abstract class Item {
  // We can't require subtypes to provide an itemType, so this is the best we can do.
  String get itemType;

  ///
  static const String _CONTAINED_IN_DELIMITER = ".";

  /// These are the attribute item sets that contain this item
  final AttributeStringSet _containedIn = AttributeStringSet(
    attributeKey: "tfc_containedIn",
    syncDepth: SyncDepth.CLOUD,
  );

  // The instnace of this item
  late final SingleItemManager _itemManager;


  // Expose the itemID for getting
  late final String itemID;


  // Expose the onDelete event for listeners
  Event get onDelete {
    return _itemManager.onDelete;
  }
  

  /// Item subtypes should override this
  List<Attribute> getAllAttributes();
  List<Attribute> _getAllAttributes() {
    List<Attribute> allAttributes = getAllAttributes();
    allAttributes.add(_containedIn);
    return allAttributes;
  }


  /**Creates a new item */
  Item.createNew() {
    // Create a list to collect changes in
    List<Change> changes = [];

    // Create the item creation change
    this.itemID = AllItemsManager.requestNewItemID(itemType: itemType);
    changes.add(
      ChangeItemCreation(
        changeApplicationDepth: SyncDepth.CLOUD,
        itemType: itemType,
        itemID: itemID,
      ),
    );

    // Create an attribute init change for each attribute
    for (Attribute attribute in _getAllAttributes()) {
      changes.add(
        attribute.getAttributeInitChange(itemID: itemID),
      );
    }

    // Create the new item isntance
    AllItemsManager.applyChangesIfRelevant(changes: changes);
    
    // Record the new item instance
    _itemManager = AllItemsManager.getItemInstance(itemID)!;

    // Wire up the attributes
    _connectAttributesToAttributeInstances();
  }

  /** Creates a new item control pannel for the item with the given itemID. */
  Item.fromItemID(String itemID) {
    this.itemID = itemID;
    _itemManager = AllItemsManager.getItemInstance(itemID)!;
    _connectAttributesToAttributeInstances();
  }


  /** Sets up all the attributes in this item */
  void _connectAttributesToAttributeInstances() {
    for (Attribute attribute in _getAllAttributes()) {
      attribute.connectToAttributeInstance(
        itemManager: _itemManager,
      );
    }
  }


  /** Permanently delete this item */
  void delete() {
    List<Change> changes = [];

    // Delete this item.
    changes.add(
      ChangeItemDeletion(
        itemType: itemType,
        itemID: itemID,
        changeApplicationDepth: SyncDepth.CLOUD,
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
          value: itemID,
          changeApplicationDepth: SyncDepth.CLOUD,
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
