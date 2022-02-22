part of tke_item_store;

/// Computes a value, and triggers an onAfterChange event whenever any of the dependencies change.
class Math {
  static Getter<d> max<d extends num?>(Getter<d> numA, Getter<d> numB) {
    return Computed(
      () {
        if (numA.value == null || numB.value == null) {
          return null as d;
        } else if (numA.value! > numB.value!) {
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

  static Getter<d> min<d extends num?>(Getter<d> numA, Getter<d> numB) {
    return Computed(
      () {
        if (numA.value == null || numB.value == null) {
          return null as d;
        } else if (numA.value! < numB.value!) {
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
