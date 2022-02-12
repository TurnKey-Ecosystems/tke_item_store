part of tke_item_store;

/// Returns one of two different values absed on a condition
class IfElse<ValueType> implements Getter<ValueType> {
  /// Register witht he getter store
  late final String getterID = GetterStore.registerWithGetterStore(this);

  /// The condition that will change the result
  final Getter<bool> condition;

  /// The result if the condition is true
  final Getter<ValueType> ifTrue;

  /// The result if the condition is false
  final Getter<ValueType> ifFalse;

  /// Triggered any time there is a new value
  final Event onAfterChange = Event();

  /// Compute the value
  ValueType getValue() => condition.value
    ? ifTrue.value
    : ifFalse.value;

  /// Compute the value
  ValueType get value => getValue();


  /// Created a new IfElse computer
  IfElse(
    this.condition,
    {
      required this.ifTrue,
      required this.ifFalse,
    }
  ) {
    condition.onAfterChange.addListener(onAfterChange.trigger);
    ifTrue.onAfterChange.addListener(onAfterChange.trigger);
    ifFalse.onAfterChange.addListener(onAfterChange.trigger);
  }
  
  @override
  String toString() {
    return GetterStore.getterToString(this);
  }

  bool operator ==(dynamic other) => other is Getter<ValueType> && this.value == other.value;
  @override
  int get hashCode => getValue().hashCode;
}