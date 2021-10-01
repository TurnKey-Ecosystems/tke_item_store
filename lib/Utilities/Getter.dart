part of tke_item_store;

abstract class Getter<ValueType> implements OnAfterChange {
  Event get onAfterChange;
  ValueType getValue();
  ValueType get value;
}