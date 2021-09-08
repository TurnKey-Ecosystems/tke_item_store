part of tke_flutter_core_v_3_0;

class BasicValueWrapper<ValueType> implements OnAfterChange {
  // On changed event
  final Event onAfterChange = Event();

  // Values
  ValueType _value;
  ValueType get value {
    return _value;
  }
  ValueType getValue() {
    return _value;
  }
  void set value(ValueType newValue) {
    if (newValue != _value) {
      _value = newValue;
      onAfterChange.trigger();
    }
  }
  void setValue(ValueType newValue) {
    if (newValue != _value) {
      _value = newValue;
      onAfterChange.trigger();
    }
  }

  BasicValueWrapper(this._value);
}




/** */
class GetSetWrapper<ValueType> implements BasicValueWrapper<ValueType> {
  // On changed event
  final Event onAfterChange = Event();

  // Getters
  ValueType Function() _getValue;
  ValueType get _value {
    return _getValue();
  }
  ValueType getValue() {
    return _getValue();
  }
  ValueType get value {
    return getValue();
  }

  // Setters
  void Function(ValueType newValue) _setValue;
  set _value(ValueType newValue) {
    _setValue(newValue);
  }
  void setValue(ValueType newValue) {
    _setValue(newValue);
    onAfterChange.trigger();
  }
  set value(ValueType newValue) {
    setValue(newValue);
  }

  // Constructor
  GetSetWrapper({
    required ValueType Function() getValue,
    required void Function(ValueType newValue) setValue,
  })
      : _getValue = getValue,
        _setValue = setValue;
}