part of tke_item_store;

/// Computes a value, and triggers an onAfterChange event whenever any of the dependencies change.
class Computed<ValueType> implements Getter<ValueType> {
  /// Register witht he getter store
  late final String getterID = GetterStore.registerWithGetterStore(this);

  /// Triggered any time there is a new value
  final Event onAfterChange; // = Event();

  /// Compute the value. Only change this if you know what you are doing.
  ValueType Function() computeValue;

  /// Recompute the value. Only change this if you know what you are doing.
  void recompute() {
    final oldCachedValue = _cachedValue;
    try {
      _cachedValue = computeValue();
      _haveCachedValue = true;
    } catch (e) {
      _haveCachedValue = false;
    }
    if (_cachedValue != oldCachedValue) {
      onAfterChange.trigger();
    }
  }

  /// Compute the value
  late final int tempRecomputeHashCode;

  /// Whether or not we've cached a value yet.
  bool _haveCachedValue = false;

  /// The computed value
  ValueType? _cachedValue;

  /// Return the computed value
  ValueType getValue() {
    if (!_haveCachedValue) {
      _cachedValue = computeValue();
      _haveCachedValue = true;
    }
    return _cachedValue as ValueType;
  }

  /// Return the computed value
  ValueType get value => getValue();

  /// Created a new computed value
  Computed(
    this.computeValue, {
    required List<Event?> recomputeTriggers,
  }) : onAfterChange = Event() {
    try {
      _cachedValue = computeValue();
      _haveCachedValue = true;
    } catch (e) {}

    // If any of the dependencies change, then recompute and notify listenners
    tempRecomputeHashCode = recompute.hashCode;
    for (Event? event in recomputeTriggers) {
      event?.addListener(recompute);
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
