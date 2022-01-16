part of tke_item_store;

/// Computes a value, and triggers an onAfterChange event whenever any of the dependencies change.
class Computed<ValueType> implements Getter<ValueType> {
  /// Triggered any time there is a new value
  final Event onAfterChange = Event();

  /// Compute the value
  final ValueType Function() computeValue;
  ValueType getValue() {
    return computeValue();
  }

  /// Compute the value
  ValueType get value => getValue();


  /// Created a new computed value
  Computed(
    this.computeValue,
    {
      required List<Event?> recomputeTriggers,
    }
  ) {
    // If any of the dependencies change, then let listenners know
    for (Event? event in recomputeTriggers) {
      event?.addListener(onAfterChange.trigger);
    }
  }

  bool operator ==(dynamic other) => other is Getter<ValueType> && this.value == other.value;
  @override
  int get hashCode => getValue().hashCode;
}