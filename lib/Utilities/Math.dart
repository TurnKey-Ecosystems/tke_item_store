part of tke_item_store;

/// Computes a value, and triggers an onAfterChange event whenever any of the dependencies change.
class Math<ValueType> {
  static Getter<double> max(Getter<double> numA, Getter<double> numB) {
    return Computed(
      () {
        if (numA.value > numB.value) {
          return numA.value;
        } else {
          return numB.value;
        }
      },
      recomputeTriggers: [
        numA.onAfterChange,
        numB.onAfterChange,
      ],
    );
  }

  static Getter<double> min(Getter<double> numA, Getter<double> numB) {
    return Computed(
      () {
        if (numA.value < numB.value) {
          return numA.value;
        } else {
          return numB.value;
        }
      },
      recomputeTriggers: [
        numA.onAfterChange,
        numB.onAfterChange,
      ],
    );
  }
}