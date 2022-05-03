part of tke_item_store;

/// Computes a value, and triggers an onAfterChange event whenever any of the dependencies change.
class Computed<ValueType> implements Getter<ValueType> {
  /// Register witht he getter store
  late final String getterID = GetterStore.registerWithGetterStore(this);

  /// Triggered any time there is a new value
  final Event onAfterChange = Event();

  /// Compute the value
  final ValueType Function() _computeValue;

  /// The computed value
  late ValueType _cachedValue;

  /// Return the computed value
  ValueType getValue() => _cachedValue;

  /// Return the computed value
  ValueType get value => _cachedValue;

  /// Created a new computed value
  Computed(
    this._computeValue, {
    required List<Event?> recomputeTriggers,
  }) {
    _cachedValue = _computeValue();

    // If any of the dependencies change, then recompute and notify all listenners
    for (Event? event in recomputeTriggers) {
      event?.addListener(() {
        _cachedValue = _computeValue();
        onAfterChange.trigger();
      });
    }
  }

  @override
  String toString() {
    return GetterStore.getterToString(this);
  }

  bool operator ==(dynamic other) =>
      other is Getter<ValueType> && this.value == other.value;
  @override
  int get hashCode => getValue().hashCode;
}
