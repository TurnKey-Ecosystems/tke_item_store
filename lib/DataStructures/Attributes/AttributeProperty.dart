part of tke_item_store;


// Provides a control pannel for an instance of a property type attribute
abstract class _AttributeProperty<PropertyType> extends Attribute implements BasicValueWrapper<PropertyType> {
  // TODO: Implementing BasicValueWrapper requies us to have this. Fix that in future.
  late PropertyType _value;

  // Expose the value of the attribute
  PropertyType get value {
    return attributeInstance.valueAsProperty;
  }
  PropertyType getValue() {
    return value;
  }


  // Changes to the attribute made through this class are considered local changes
  void set value(PropertyType newValue) {
    AllItemsManager.applyChangesIfRelevant(
      changes: [
        ChangeAttributeSetValue(
          changeApplicationDepth: syncDepth,
          itemID: attributeInstance.itemID,
          attributeKey: attributeKey,
          value: newValue,
        ),
      ],
    );
  }
  void setValue(PropertyType newValue) {
    value = newValue;
  }


  // This is the value this attribute should have when it's item is first created.
  final PropertyType valueOnCreateNew;


  // Creates a new property attribute
  _AttributeProperty({
    required String attributeKey,
    required SyncDepth syncDepth,
    required this.valueOnCreateNew,
  })
    : _value = valueOnCreateNew,
      super(
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



// Provides a control pannel for an instance of a boolean attribute
class AttributeBool extends _AttributeProperty<bool> {
  AttributeBool({
    required String attributeKey,
    required SyncDepth syncDepth,
    required bool valueOnCreateNew,
  }) : super(
    attributeKey: attributeKey,
    syncDepth: syncDepth,
    valueOnCreateNew: valueOnCreateNew
  );
}



// Provides a control pannel for an instance of an int attribute
class AttributeInt extends _AttributeProperty<int> {
  AttributeInt({
    required String attributeKey,
    required SyncDepth syncDepth,
    required int valueOnCreateNew,
  }) : super(
    attributeKey: attributeKey,
    syncDepth: syncDepth,
    valueOnCreateNew: valueOnCreateNew
  );
}



// Provides a control pannel for an instance of a double attribute
class AttributeDouble extends _AttributeProperty<double> {
  AttributeDouble({
    required String attributeKey,
    required SyncDepth syncDepth,
    required double valueOnCreateNew,
  }) : super(
    attributeKey: attributeKey,
    syncDepth: syncDepth,
    valueOnCreateNew: valueOnCreateNew
  );
}



// Provides a control pannel for an instance of a String attribute
class AttributeString extends _AttributeProperty<String> {
  AttributeString({
    required String attributeKey,
    required SyncDepth syncDepth,
    required String valueOnCreateNew,
  }) : super(
    attributeKey: attributeKey,
    syncDepth: syncDepth,
    valueOnCreateNew: valueOnCreateNew
  );
}



// Provides a control pannel for an instance of a session exlusive object attribute
class AttributeSessionObject<ObjectType> extends _AttributeProperty<ObjectType> {
  AttributeSessionObject({
    required String attributeKey,
    required ObjectType valueOnCreateNew,
  }) : super(
    attributeKey: attributeKey,
    syncDepth: SyncDepth.SESSION,
    valueOnCreateNew: valueOnCreateNew
  );
}