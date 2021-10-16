part of tke_item_store;

abstract class IGetter<ValueType> implements OnAfterChange {
  Event get onAfterChange;
  ValueType getValue();
  ValueType get value;
}