part of tke_flutter_core_v_3_0;


// Provides a control pannel for an instance of an item attribute
class AttributeItem<ItemClassType extends Item> extends Attribute {
  // We can't require constructors on items, so we will us this instead.
  final ItemClassType Function(String) getItemFromItemID;

  // Expose the value of the attribute
  ItemClassType get value {
    return getItemFromItemID(attributeInstance.valueAsProperty);
  }

  // Changes to the attribute made through this class are considered local changes
  void set value(ItemClassType newValue) {
    AllItemsManager.applyChangesIfRelevant(
      changes: [
        ChangeAttributeSetValue(
          changeApplicationDepth: syncDepth,
          itemID: attributeInstance.itemID,
          attributeKey: attributeKey,
          value: newValue.itemID,
        ),
      ],
    );
  }


  // Allow devs to define their own default values
  final ItemClassType Function() getDefaultItemOnCreateNew;

  // This is the value this attribute should have when it's item is first created.
  String get valueOnCreateNew {
    return getDefaultItemOnCreateNew().itemID;
  }


  // Creates a new property attribute
  AttributeItem({
    required String attributeKey,
    required SyncDepth syncDepth,
    required this.getDefaultItemOnCreateNew,
    required this.getItemFromItemID,
  }) : super(
    attributeKey: attributeKey,
    syncDepth: syncDepth,
  );
  

  /** Gets the attribute init change object for this attribute. */
  @override
  ChangeAttributeInit getAttributeInitChange({
    required String itemID,
  }) {
    return ChangeAttributeInit.property(
      changeApplicationDepth: syncDepth,
      itemID: itemID,
      attributeKey: attributeKey,
      value: valueOnCreateNew,
    );
  }
}