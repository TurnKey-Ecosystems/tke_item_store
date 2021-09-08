part of tke_item_store;


/// Provides a control pannel for an instance of a set of strings attribute
class AttributeStringSet extends Attribute {
  /// Allow devs to access the elements in this set
  Set<String> get allElements {
    Set<String> allElements = {};
    for (String element in attributeInstance.getAllValuesAsSet<String>()) {
      allElements.add(
        element,
      );
    }
    return allElements;
  }


  /// Changes to the attribute made through this class are considered local changes
  void add(String newElement) {
    AllItemsManager.applyChangesIfRelevant(
      changes: [
        ChangeAttributeAddValue(
          changeApplicationDepth: syncDepth,
          itemID: attributeInstance.itemID,
          attributeKey: attributeKey,
          value: newElement,
        ),
      ],
    );
  }

  /// Changes to the attribute made through this class are considered local changes
  void remove(String elementToRemove) {
    AllItemsManager.applyChangesIfRelevant(
      changes: [
        ChangeAttributeRemoveValue(
          changeApplicationDepth: syncDepth,
          itemID: attributeInstance.itemID,
          attributeKey: attributeKey,
          value: elementToRemove,
        ),
      ],
    );
  }


  // Creates a new attribute item set
  AttributeStringSet({
    required String attributeKey,
    required SyncDepth syncDepth,
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
}