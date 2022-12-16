part of tke_item_store;

// Provides a control pannel for an instance of an item attribute
class AttributeItemSet<ItemClassType extends Item> extends Attribute
    implements Getter<ObservableSet<ItemClassType>> {
  /// Register witht he getter store
  late final String getterID = GetterStore.registerWithGetterStore(this);

  // We can't require constructors on items, so we will us this instead.
  final ItemClassType Function(String) getItemFromItemID;

  @override
  ObservableSet<ItemClassType> getValue() => value;

  // Allow devs to access the items in this set
  ObservableSet<ItemClassType> get value {
    ObservableSet<ItemClassType> allItems = ObservableSet();
    for (String itemID in attributeInstance.value.getAllValuesAsSet<String>()) {
      allItems.add(
        getItemFromItemID(itemID).g,
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
          itemID: _itemManager.value.itemID,
          attributeKey: attributeKey,
          value: newItem.itemID.value,
        ),
      ],
    );
    newItem._containedIn.add(
      _itemManager.value.itemID + Item._CONTAINED_IN_DELIMITER + attributeKey,
    );
  }

  // Changes to the attribute made through this class are considered local changes
  void remove(ItemClassType itemToRemove) {
    AllItemsManager.applyChangesIfRelevant(
      changes: [
        ChangeAttributeRemoveValue(
          changeApplicationDepth: syncDepth,
          itemID: _itemManager.value.itemID,
          attributeKey: attributeKey,
          value: itemToRemove.itemID.value,
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
    final initItemId = _itemManager.value.itemID;
    final attributeInstanceForInitItem = attributeInstance.value;
    if (!_deleteContentsOnItemDeleteListeners.containsKey(initItemId)) {
      _deleteContentsOnItemDeleteListeners[initItemId] = {};
    }

    // Add a listenner if there is none for this attribute
    Map<String, void Function()> onDeleteItemEntry =
        _deleteContentsOnItemDeleteListeners[initItemId]!;
    if (!onDeleteItemEntry.containsKey(attributeKey)) {
      onDeleteItemEntry[attributeKey] = () {
        // Delete all of this sets contents
        for (final contentItemId in attributeInstanceForInitItem.getAllValuesAsSet<String>()) {
          getItemFromItemID(contentItemId).delete();
        }

        // The item will be deleted, so their is no sense is listening any more
        onDeleteItemEntry.remove(attributeKey);
      };
      AllItemsManager.getItemInstance(initItemId)!
          .onDelete
          .addListener(onDeleteItemEntry[attributeKey]);
    }
  }

  // Creates a new attribute item set
  AttributeItemSet({
    required String attributeKey,
    SyncDepth? syncDepth,
    required this.getItemFromItemID,
    required this.shouldDeleteContentsWhenItemIsDeleted,
    required Getter<SingleItemManager> itemManager,
    required Item itemClassInstance,
  }) : super(
          attributeKey: attributeKey,
          syncDepth: syncDepth,
          itemManager: itemManager,
          itemClassInstance: itemClassInstance,
        ) {
    // If this is a defining relationship, then delete the contents of this Set when the item is deleted
    if (shouldDeleteContentsWhenItemIsDeleted) {
      _listenToOnDeleteAndDeleteContents();
    }
  }

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
}
