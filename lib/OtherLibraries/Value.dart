import 'package:tke_item_store/project_library.dart';

import 'Event.dart';

class Value<ValueType> with Getter<ValueType>, Setter<ValueType> implements G<ValueType>, S<ValueType> {
  ValueType Function() _getValue = (() => null as ValueType);
  ValueType getValue() {
    return _getValue();
  }
  Value.ofNewVariable(ValueType intialValue) {
    _VariableWrapper<ValueType> wrapper = _VariableWrapper(intialValue);
    _getValue = wrapper.getValue;
    _setValue = wrapper.setValue;
    wrapper.onAfterChange.addListener(_onAfterChange.trigger);
  }
  Value.fromFunctions({
    required ValueType Function() get,
    required void Function(ValueType newValue) set,
    List<Event?>? onAfterChangeTriggers,
  }) {
    _getValue = get;
    _setValue = set;
    onAfterChangeTriggers?.forEach((Event? trigger) {
      trigger?.addListener(_onAfterChange.trigger);
    });
  }
}



class V<ValueType> extends Value<ValueType> {
  V(ValueType initialValue) : super.ofNewVariable(initialValue);
  V.f({
    required ValueType Function() get,
    required void Function(ValueType newValue) set,
    List<Event?>? onAfterChangeTriggers,
  }) : super.fromFunctions(
        get: get,
        set: set,
        onAfterChangeTriggers: onAfterChangeTriggers,
      );
}



abstract class Getter<ValueType> {
  final Event _onAfterChange = Event();
  Event get onAfterChange {
    return _onAfterChange;
  }
  /// This is initialized with a stand-in, it must be replaced in the constructor!
  //ValueType Function() _getValue = (() => null as ValueType);
  ValueType getValue();
  ValueType get value {
    return getValue();
  }
  static Getter<ValueType> ofNewVariable<ValueType>(ValueType initialValue)
    => Value.ofNewVariable(initialValue);
  static Getter<ValueType> fromFunction<ValueType>(ValueType Function() get, { List<Event?>? onAfterChangeTriggers })
    => Value.fromFunctions(get: get, set: ((_) => null), onAfterChangeTriggers: onAfterChangeTriggers);
  @override
  int get hashCode => getValue().hashCode;
}



class ConstGetter<ValueType> implements Getter<ValueType> {
  final Event _onAfterChange = const Event.unchanging();
  Event get onAfterChange {
    return _onAfterChange;
  }
  /// This is initialized with a stand-in, it must be replaced in the constructor!
  final ValueType constValue;
  ValueType getValue() {
    return constValue;
  }
  ValueType get value {
    return getValue();
  }

  const ConstGetter(this.constValue);
}



class G<ValueType> extends Getter<ValueType> {
  ValueType getValue() => null as ValueType;
  factory G(ValueType initialValue)
    => Value.ofNewVariable(initialValue);
  factory G.f(ValueType Function() get, { List<Event?>? onAfterChangeTriggers })
    => Value.fromFunctions(get: get, set: ((_) => null), onAfterChangeTriggers: onAfterChangeTriggers);
}



abstract class Setter<ValueType> {
  /// This is initialized with a stand-in, it must be replaced in the constructor!
  void Function(ValueType newValue) _setValue = ((_) => null);
  void setValue(ValueType newValue) {
    _setValue(newValue);
  }
  void set value(ValueType newValue) {
    _setValue(newValue);
  }
  static Setter<ValueType> ofNewVariable<ValueType>(ValueType initialValue)
    => S.v(initialValue);
  static Setter<ValueType> fromFunction<ValueType>(void Function(ValueType newValue) set)
    => S(set);
}



class S<ValueType> extends Setter<ValueType> {
  factory S.v(ValueType initialValue) => Value.ofNewVariable(initialValue);
  factory S(void Function(ValueType newValue) set) => Value.fromFunctions(set: set, get: (() => null as ValueType));
}



class _VariableWrapper<VariableType> {
  Event onAfterChange = Event();
  VariableType _variable;
  VariableType getValue() {
    return _variable;
  }
  void setValue(VariableType newValue) {
    _variable = newValue;
    onAfterChange.trigger();
  }
  _VariableWrapper(this._variable);
}



extension VariableToGetterOrValue<ValueType> on ValueType {
  Value<ValueType> get v {
    return Value.ofNewVariable(this);
  }

  Getter<ValueType> get g {
    return Getter.ofNewVariable(this);
  }
}



extension FuncToGetter<ValueType> on ValueType Function() {
  Getter<ValueType> get g {
    return Getter.fromFunction(this);
  }
}



extension FuncToSetter<ValueType> on void Function(ValueType) {
  Setter<ValueType> get s {
    return Setter.fromFunction(this);
  }
}



typedef Num = Value<double>;
typedef Bool = Value<bool>;
//typedef Text = Value<string>;

/*abstract class ReadOnly<GetterType extends Getter<ValueType>, ValueType> implements Getter<ValueType> {
  Event get _onAfterChange;
  Event get onAfterChange;
  ValueType getValue();
  ValueType get value;
}*/

extension BasicDoubleArithmetic on Getter<double> {
  Getter<double> operator +(Getter<double> other) {
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
  
  Getter<double> operator -(Getter<double> other) {
    return Computed(
      () {
        return this.value - other.value;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }
  
  Getter<double> operator *(Getter<double> other) {
    return Computed(
      () {
        return this.value * other.value;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }
  
  Getter<double> operator /(Getter<double> other) {
    return Computed(
      () {
        return this.value / other.value;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }
  
  Getter<double> operator %(Getter<double> other) {
    return Computed(
      () {
        return this.value % other.value;
      },
      recomputeTriggers: [
        this.onAfterChange,
        other.onAfterChange,
      ],
    );
  }
}


// Patterns:
// - Big classes with a lot of allowed configuration.
// - Push branching decisions as low down in the configuration tree as possible.
// - Use Getter, Setter, and Value instead of basic types.