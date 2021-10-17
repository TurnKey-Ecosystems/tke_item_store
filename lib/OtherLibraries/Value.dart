import 'Event.dart';

class Value<ValueType> with Getter<ValueType>, Setter<ValueType> implements G<ValueType>, S<ValueType> {
  Value.ofNewVariable(ValueType intialValue) {
    _VariableWrapper<ValueType> wrapper = _VariableWrapper(intialValue);
    _getValue = wrapper.getValue;
    _setValue = wrapper.setValue;
    _onAfterChange = wrapper.onAfterChange;
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
  Event _onAfterChange = Event();
  Event get onAfterChange {
    return _onAfterChange;
  }
  /// This is initialized with a stand-in, it must be replaced in the constructor!
  ValueType Function() _getValue = (() => null as ValueType);
  ValueType getValue() {
    return _getValue();
  }
  ValueType get value {
    return _getValue();
  }
  static Getter<ValueType> ofNewVariable<ValueType>(ValueType initialValue)
    => G(initialValue);
  static Getter<ValueType> fromFunctions<ValueType>(ValueType Function() get, { List<Event?>? onAfterChangeTriggers })
    => G.f(get, onAfterChangeTriggers: onAfterChangeTriggers);
}



class G<ValueType> extends Getter<ValueType> {
  factory G(ValueType initialValue) => Value.ofNewVariable(initialValue);
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


// Patterns:
// - Big classes with a lot of allowed configuration.
// - Push branching decisions as low down in the configuration tree as possible.
// - Use Getter, Setter, and Value instead of basic types.