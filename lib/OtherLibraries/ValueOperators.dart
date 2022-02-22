import 'package:tke_item_store/project_library.dart';

extension GetterIntConversion<T extends num> on Getter<T> {
  Getter<int> toInt() => Computed(
        () => this.value.toInt(),
        recomputeTriggers: [
          this.onAfterChange,
        ],
      );

  Getter<double> toDouble() => Computed(
        () => this.value.toDouble(),
        recomputeTriggers: [
          this.onAfterChange,
        ],
      );

  Getter<T?> asNullable() => Computed(
        () => this.value,
        recomputeTriggers: [
          this.onAfterChange,
        ],
      );

  Getter<T> asNonNullable() => Computed(
        () => this.value,
        recomputeTriggers: [
          this.onAfterChange,
        ],
      );
}

extension GetterIntNullableConversion<T extends num> on Getter<T?> {
  Getter<int?> toInt() => Computed(
        () => this.value?.toInt(),
        recomputeTriggers: [
          this.onAfterChange,
        ],
      );

  Getter<double?> toDouble() => Computed(
        () => this.value?.toDouble(),
        recomputeTriggers: [
          this.onAfterChange,
        ],
      );

  Getter<T?> asNullable() => Computed(
        () => this.value,
        recomputeTriggers: [
          this.onAfterChange,
        ],
      );

  Getter<T> asNonNullable() => Computed(
        () => this.value!,
        recomputeTriggers: [
          this.onAfterChange,
        ],
      );
}

/// This defines all the arithmetic operators for Getter<double>'s and Getter<double?>'s.
extension GetterDoubleNullableOperators on Getter<num?> {
  Getter<double?> operator +(Getter<num?> other) {
    return Computed(
      () {
        if (this.value == null || other.value == null) {
          return null;
        } else {
          return this.value!.toDouble() + other.value!.toDouble();
        }
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<double?> operator -(Getter<num?> other) {
    return Computed(
      () {
        if (this.value == null || other.value == null) {
          return null;
        } else {
          return this.value!.toDouble() - other.value!.toDouble();
        }
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<double?> operator *(Getter<num?> other) {
    return Computed(
      () {
        if (this.value == null || other.value == null) {
          return null;
        } else {
          return this.value!.toDouble() * other.value!.toDouble();
        }
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<double?> operator /(Getter<num?> other) {
    return Computed(
      () {
        if (this.value == null || other.value == null) {
          return null;
        } else {
          return this.value!.toDouble() / other.value!.toDouble();
        }
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<double?> operator %(Getter<num?> other) {
    return Computed(
      () {
        if (this.value == null || other.value == null) {
          return null;
        } else {
          return this.value!.toDouble() % other.value!.toDouble();
        }
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }
}

extension GetterDoubleNonNullableOperators on Getter<num> {
  Getter<double> operator +(Getter<num> other) {
    return Computed(
      () => this.value.toDouble() + other.value.toDouble(),
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<double> operator -(Getter<num> other) {
    return Computed(
      () => this.value.toDouble() - other.value.toDouble(),
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<double> operator *(Getter<num> other) {
    return Computed(
      () => this.value.toDouble() * other.value.toDouble(),
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<double> operator /(Getter<num> other) {
    return Computed(
      () => this.value.toDouble() / other.value.toDouble(),
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<double> operator %(Getter<num> other) {
    return Computed(
      () => this.value.toDouble() % other.value.toDouble(),
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<bool> operator <(Getter<num> other) {
    return Computed(
      () {
        return this.value < other.value;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<bool> operator <=(Getter<num> other) {
    return Computed(
      () {
        return this.value <= other.value;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<bool> operator >=(Getter<num> other) {
    return Computed(
      () {
        return this.value >= other.value;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<bool> operator >(Getter<num> other) {
    return Computed(
      () {
        return this.value > other.value;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }
}

/// This defines all the arithmetic operators for Getter<num>'s.
extension GetterStringOperators on Getter<String> {
  Getter<String> operator +(Getter<String> other) {
    return Computed(
      () {
        return this.value + other.value;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<bool> operator <(Getter<String> other) {
    return Computed(
      () {
        return this.value.compareTo(other.value) < 0;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<bool> operator <=(Getter<String> other) {
    return Computed(
      () {
        return this.value.compareTo(other.value) <= 0;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<bool> operator >=(Getter<String> other) {
    return Computed(
      () {
        return this.value.compareTo(other.value) >= 0;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<bool> operator >(Getter<String> other) {
    return Computed(
      () {
        return this.value.compareTo(other.value) > 0;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<String> operator [](Getter<int> index) {
    return Computed(
      () {
        return this.value[index.value];
      },
      recomputeTriggers: [
        this.onAfterChange,
        index.onAfterChange,
      ],
    );
  }
}

/// This defines all the arithmetic operators for Getter<num>'s.
extension GetterBooleanOperators on Getter<bool> {
  Getter<bool> and(Getter<bool> other) {
    return Computed(
      () {
        return this.value && other.value;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<bool> operator &(Getter<bool> other) {
    return this.and(other);
  }

  Getter<bool> or(Getter<bool> other) {
    return Computed(
      () {
        return this.value || other.value;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<bool> operator |(Getter<bool> other) {
    return this.or(other);
  }

  Getter<bool> not() {
    return Computed(
      () {
        return !this.value;
      },
      recomputeTriggers: [
        this.onAfterChange,
      ],
    );
  }

  Getter<bool> doesEqual(Getter<bool> other) {
    return Computed(
      () {
        return this.value == other.value;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }

  Getter<bool> doesNotEqual(Getter<bool> other) {
    return Computed(
      () {
        return this.value != other.value;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }
}

Getter<int> a = 2.g;
Getter<int> b = 3.g;
Getter<int> c = (a + b).toInt();
Getter<double> d = 2.0.g;
Getter<double> e = 3.0.g;
Getter<double> f = d + e;
Getter<double?> g = null.g;
Getter<double?> h = null.g;
Getter<double?> i = g + null.g;
Getter<double?> j = d.asNullable() + g;
Getter<double?> k = d + e;
Getter<double> l = d + a;
