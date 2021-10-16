import 'Event.dart';

class Value<ValueType> implements Getter<ValueType>, Setter<ValueType> {
  Event _onAfterChange = Event();
  Event get onAfterChange {
    return _onAfterChange;
  }
  ValueType Function() _getValue;
  ValueType getValue() {
    return _getValue();
  }
  ValueType get value {
    return _getValue();
  }
  void Function(ValueType newValue) _setValue;
  void setValue(ValueType newValue) {
    _setValue(newValue);
  }
  void set value(ValueType newValue) {
    _setValue(newValue);
  }
  Value.ofVariable(ValueType intialValue)
    : _getValue = (() => intialValue),
      _setValue = ((_) => null)
  {
    _VariableWrapper<ValueType> wrapper = _VariableWrapper(intialValue);
    _getValue = wrapper.getValue;
    _setValue = wrapper.setValue;
    _onAfterChange = wrapper.onAfterChange;
  }
  Value.fromFunctions({
    required ValueType Function() get,
    required void Function(ValueType newValue) set,
    List<Event?>? onAfterChangeTriggers,
  })
    : _getValue = get,
      _setValue = set
  {
    onAfterChangeTriggers?.forEach((Event? trigger) {
      trigger?.addListener(_onAfterChange.trigger);
    });
  }
}



abstract class V<ValueType> extends Value<ValueType> {
  V(ValueType initialValue) : super.ofVariable(initialValue);
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



abstract class Getter<ValueType> implements G<ValueType> {
  factory Getter.ofVariable(ValueType initialValue)
    => Value.ofVariable(initialValue);
  factory Getter.fromFunction(ValueType Function() get, { List<Event?>? onAfterChangeTriggers })
    => Value.fromFunctions(get: get, set: (_) => null, onAfterChangeTriggers: onAfterChangeTriggers);
}



abstract class G<ValueType> {
  Event get onAfterChange;
  ValueType getValue();
  ValueType get value;
  factory G(ValueType initialValue)
    => Value.ofVariable(initialValue);
  factory G.f(ValueType Function() get, { List<Event?>? onAfterChangeTriggers })
    => Value.fromFunctions(get: get, set: (_) => null, onAfterChangeTriggers: onAfterChangeTriggers);
}



abstract class Setter<ValueType> implements S<ValueType> {
  factory Setter.ofVariable(ValueType initialValue)
    => Value.ofVariable(initialValue);
  factory Setter.fromFunction(void Function(ValueType newValue) set)
    => Value.fromFunctions(get: (() => null) as ValueType Function(), set: set);
}



abstract class S<ValueType> {
  void setValue(ValueType newValue);
  void set value(ValueType newValue);
  factory S.v(ValueType initialValue)
    => Value.ofVariable(initialValue);
  factory S(void Function(ValueType newValue) set)
    => Value.fromFunctions(get: (() => null) as ValueType Function(), set: set);
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