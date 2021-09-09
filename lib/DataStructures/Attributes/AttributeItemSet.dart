part of tke_item_store;


// Provides a control pannel for an instance of an item attribute
class AttributeItemSet<ItemClassType extends Item> extends Attribute {
  // We can't require constructors on items, so we will us this instead.
  final ItemClassType Function(String) getItemFromItemID;

  // Allow devs to access the items in this set
  Set<ItemClassType> get allItems {
    Set<ItemClassType> allItems = {};
    for (String itemID in attributeInstance!.getAllValuesAsSet<String>()) {
      allItems.add(
        getItemFromItemID(itemID),
      );
    }
    return allItems;
  }


  // Changes to the attribute made through this class are considered local changes
  void add(ItemClassType newItem) {
    AllItemsManager.applyChangesIfRelevant(
      changes: [
        ChangeAttributeAddValue(
          changeApplicationDepth: syncDepth,
          itemID: attributeInstance!.itemID,
          attributeKey: attributeKey,
          value: newItem.itemID,
        ),
      ],
    );
    newItem._containedIn.add(
      attributeInstance!.itemID
      + Item._CONTAINED_IN_DELIMITER
      + attributeKey,
    );
  }

  // Changes to the attribute made through this class are considered local changes
  void remove(ItemClassType itemToRemove) {
    AllItemsManager.applyChangesIfRelevant(
      changes: [
        ChangeAttributeRemoveValue(
          changeApplicationDepth: syncDepth,
          itemID: attributeInstance!.itemID,
          attributeKey: attributeKey,
          value: itemToRemove.itemID,
        ),
      ],
    );
  }


  // Whether or not to delete all children when the parent object is deleted
  final bool shouldDeleteContentsWhenItemIsDeleted;

  // Keeps track of the onDelete listenners by item
  static Map<String, Map<String, void Function()>> _deleteContentsOnItemDeleteListeners = {};

  // This will setup a listener to delete all contents when the parent item is deleted
  void _listenToOnDeleteAndDeleteContents() {
    // Ensure a slot exists for this item
    if (!_deleteContentsOnItemDeleteListeners.containsKey(attributeInstance!.itemID)) {
      _deleteContentsOnItemDeleteListeners[attributeInstance!.itemID] = {};
    }

    // Add a listenner if there is none for this attribute
    Map<String, void Function()> onDeleteItemEntry =
      _deleteContentsOnItemDeleteListeners[attributeInstance!.itemID]!;
    if (!onDeleteItemEntry.containsKey(attributeKey)) {
      onDeleteItemEntry[attributeKey] = () {
        // Delete all of this sets contents
        for (ItemClassType item in allItems) {
          item.delete();
        }

        // The item will be deleted, so their is no sense is listening any more
        onDeleteItemEntry.remove(attributeKey);
      };
      AllItemsManager.getItemInstance(attributeInstance!.itemID)!.onDelete.addListener(onDeleteItemEntry[attributeKey]);
    }
  }


  // Creates a new attribute item set
  AttributeItemSet({
    required String attributeKey,
    required SyncDepth syncDepth,
    required this.getItemFromItemID,
    required this.shouldDeleteContentsWhenItemIsDeleted,
  }) : super(
    attributeKey: attributeKey,
    syncDepth: syncDepth,
  );


  /** Gets the attribute init change object for this attribute. */
  @override
  ChangeAttributeInit getAttributeInitChange({
    required String itemID,
  }) {
    return ChangeAttributeInit.set(
      changeApplicationDepth: syncDepth,
      itemID: itemID,
      attributeKey: attributeKey,
    );
  }
  

  /** After the attributes are setup, then we want to listen for the item being deleted */
  @override
  void connectToAttributeInstance({
    required SingleItemManager itemManager,
  }) {
    super.connectToAttributeInstance(itemManager: itemManager);

    // If this is a defining relationship, then delete the contents of this Set when the item is deleted
    if (shouldDeleteContentsWhenItemIsDeleted) {
      _listenToOnDeleteAndDeleteContents();
    }
  }
}