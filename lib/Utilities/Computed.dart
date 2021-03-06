part of tke_item_store;

/// Computes a value, and triggers an onAfterChange event whenever any of the dependencies change.
class Computed<ValueType> implements Getter<ValueType> {
  /// Register witht he getter store
  late final String getterID = GetterStore.registerWithGetterStore(this);

  /// Triggered any time there is a new value
  final Event onAfterChange; // = Event();

  /// Compute the value
  final ValueType Function() _computeValue;

  /// Compute the value
  late final int tempRecomputeHashCode;

  /// Whether or not we've cached a value yet.
  bool _haveCachedValue = false;

  /// The computed value
  ValueType? _cachedValue;

  /// Return the computed value
  ValueType getValue() {
    if (!_haveCachedValue) {
      _cachedValue = _computeValue();
      _haveCachedValue = true;
    }
    return _cachedValue as ValueType;
  }

  /// Return the computed value
  ValueType get value => getValue();

  /// Created a new computed value
  Computed(
    this._computeValue, {
    required List<Event?> recomputeTriggers,
    bool shouldLog = false,
  }) : onAfterChange = Event(shouldLog: shouldLog) {
    try {
      _cachedValue = _computeValue();
      _haveCachedValue = true;
    } catch (e) {}

    // If any of the dependencies change, then recompute and notify listenners
    final recompute = () {
      final oldCachedValue = _cachedValue;
      try {
        _cachedValue = _computeValue();
        _haveCachedValue = true;
      } catch (e) {
        _haveCachedValue = false;
      }
      if (_cachedValue != oldCachedValue) {
        onAfterChange.trigger();
      }
    };
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
