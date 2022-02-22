import 'package:tke_item_store/project_library.dart';

import 'Event.dart';

class Value<ValueType> with Getter<ValueType>, Setter<ValueType> {
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

abstract class Getter<ValueType> {
  late final String getterID = GetterStore.registerWithGetterStore(this);
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

  static Getter<ValueType> ofNewVariable<ValueType>(ValueType initialValue) =>
      Value.ofNewVariable(initialValue);
  static Getter<ValueType> fromFunction<ValueType>(ValueType Function() get,
          {List<Event?>? onAfterChangeTriggers}) =>
      Value.fromFunctions(
          get: get,
          set: ((_) => null),
          onAfterChangeTriggers: onAfterChangeTriggers);

  @override
  String toString() {
    return GetterStore.getterToString(this);
  }

  bool operator ==(dynamic other) =>
      other is Getter<ValueType> && this.value == other.value;
  @override
  int get hashCode => getValue().hashCode;
}

class ConstGetter<ValueType> implements Getter<ValueType> {
  final String getterID = "notInStore";
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

  @override
  String toString() {
    return constValue.toString();
  }

  bool operator ==(dynamic other) =>
      other is Getter<ValueType> && this.value == other.value;
  @override
  int get hashCode => getValue().hashCode;
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

  static Setter<ValueType> ofNewVariable<ValueType>(ValueType initialValue) =>
      Value.ofNewVariable(initialValue);
  static Setter<ValueType> fromFunction<ValueType>(
          void Function(ValueType newValue) set) =>
      Value.fromFunctions(set: set, get: (() => null as ValueType));
}

class _VariableWrapper<VariableType> {
  final Event onAfterChange;
  VariableType _variable;
  VariableType getValue() {
    return _variable;
  }

  void setValue(VariableType newValue) {
    if (_variable is Item) {
      newValue as Item;
      if ((_variable as Item).itemID.value != newValue.itemID.value) {
        (_variable as Item).setReference(newValue.itemID.value);
      }
    } else {
      if (_variable != newValue) {
        _variable = newValue;
        onAfterChange.trigger();
      }
    }
  }

  _VariableWrapper(this._variable)
      : this.onAfterChange =
            (_variable is Item) ? _variable.itemID.onAfterChange : Event();
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

extension GetterNullOperators<T> on Getter<T?> {
  Getter<T?> q(T? doSomething(T? value)) {
    return Computed(
      () => doSomething(this.value) ?? null,
      recomputeTriggers: [
        this.onAfterChange,
      ],
    );
  }
}

//typedef Num = Value<double>;
//typedef Bool = Value<bool>;
//typedef Text = Value<string>;

/*abstract class ReadOnly<GetterType extends Getter<ValueType>, ValueType> implements Getter<ValueType> {
  Event get _onAfterChange;
  Event get onAfterChange;
  ValueType getValue();
  ValueType get value;
}*/

abstract class GetterStore {
  static int _nextGetterID = 0;
  static String registerWithGetterStore<GetterType>(Getter<GetterType> getter) {
    String newGetterID = _nextGetterID.toString();
    _gettersByID[newGetterID] = getter;
    _nextGetterID++;
    return newGetterID;
  }

  static Map<String, Getter<dynamic>> _gettersByID = Map();

  static const String INLINE_GETTER_TAG = '<getter getterID="';
  static String getterToString<GetterType>(Getter<GetterType> getter) {
    return INLINE_GETTER_TAG + getter.getterID + '"/>';
  }

  static Getter<GetterType> getGetterFromID<GetterType>(String getterID) {
    return _gettersByID[getterID]! as Getter<GetterType>;
  }
}

// Patterns:
// - Big classes with a lot of allowed configuration.
// - Push branching decisions as low down in the configuration tree as possible.
// - Use Getter, Setter, and Value instead of basic types.
