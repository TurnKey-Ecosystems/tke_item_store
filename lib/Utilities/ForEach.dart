part of tke_item_store;

/// Returns one of two different values absed on a condition
class ForEach<InputValueType, ReturnValueType>
    implements Getter<ObservableList<ReturnValueType>> {
  /// Register witht he getter store
  late final String getterID = GetterStore.registerWithGetterStore(this);

  /// The condition that will change the result
  final Getter<ObservableList<InputValueType>> list;

  /// The result if the condition is true
  final Getter<ReturnValueType>? Function(Getter<InputValueType> element,
      Getter<ObservableList<ReturnValueType>> outputList) each;

  /// Triggered any time there is a new value
  final Event onAfterChange = Event();

  /// Cached value
  late ObservableList<ReturnValueType> _cachedValue;

  /// Return the computed value
  ObservableList<ReturnValueType> getValue() => _cachedValue;

  /// Return the computed value
  ObservableList<ReturnValueType> get value => _cachedValue;

  /// Created a new For computer
  ForEach({
    required this.list,
    required this.each,
  }) {
    _cachedValue = _computeValue();
    list.onAfterChange.addListener(() {
      _cachedValue = _computeValue();
      this.onAfterChange.trigger();
    });
    list.value.onElementAddedOrRemoved.addListener(() {
      _cachedValue = _computeValue();
      this.onAfterChange.trigger();
    });
  }

  /// Compute the value
  ObservableList<ReturnValueType> _computeValue() {
    ObservableList<ReturnValueType> returnList = ObservableList();
    for (Getter<InputValueType> inputElement in list.value) {
      Getter<ReturnValueType>? returnElement = each(inputElement, returnList.g);
      if (returnElement != null) {
        returnList.add(returnElement);
      }
    }
    return returnList;
  }

  @override
  String toString() {
    return GetterStore.getterToString(this);
  }

  bool operator ==(dynamic other) =>
      other is Getter<ObservableList<ReturnValueType>> &&
      this.value == other.value;
  @override
  int get hashCode => getValue().hashCode;
}
