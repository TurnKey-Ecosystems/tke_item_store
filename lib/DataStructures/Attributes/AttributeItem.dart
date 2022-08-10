part of tke_item_store;

// Provides a control pannel for an instance of an item attribute
class AttributeItem<ItemClassType extends Item?> extends Attribute implements Value<ItemClassType> {
  /// Register witht he getter store
  late final String getterID = GetterStore.registerWithGetterStore(this);

  // We can't require constructors on items, so we will us this instead.
  final ItemClassType Function(String?) getItemFromItemID;

  // Expose the value of the attribute
  ItemClassType get value {
    return getItemFromItemID(attributeInstance.value.valueAsProperty);
  }

  // Expose the value of the attribute
  ItemClassType getValue() => value;

  // Changes to the attribute made through this class are considered local changes
  void set value(ItemClassType newValue) {
    if (newValue != null) {
      AllItemsManager.applyChangesIfRelevant(
        changes: [
          ChangeAttributeSetValue(
            changeApplicationDepth: syncDepth,
            itemID: _itemManager.value.itemID,
            attributeKey: attributeKey,
            value: newValue.itemID.value,
          ),
        ],
      );
    }
  }

  @override
  void setValue(ItemClassType newValue) {
    value = newValue;
  }

  // Allow devs to define their own default values
  final ItemClassType Function() getDefaultItemOnCreateNew;

  // This is the value this attribute should have when it's item is first created.
  String? get valueOnCreateNew {
    return getDefaultItemOnCreateNew()?.itemID.value;
  }

  // Creates a new property attribute
  AttributeItem({
    required String attributeKey,
    required SyncDepth syncDepth,
    required this.getDefaultItemOnCreateNew,
    required this.getItemFromItemID,
    required Getter<SingleItemManager> itemManager,
    required Item itemClassInstance,
  }) : super(
          attributeKey: attributeKey,
          syncDepth: syncDepth,
          itemManager: itemManager,
          itemClassInstance: itemClassInstance,
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
