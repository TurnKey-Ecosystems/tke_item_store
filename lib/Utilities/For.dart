part of tke_item_store;

/// Returns one of two different values absed on a condition
class For<InputValueType, ReturnValueType>
    implements Getter<ObservableList<ReturnValueType>> {
  /// Register witht he getter store
  late final String getterID = GetterStore.registerWithGetterStore(this);

  /// The condition that will change the result
  final Getter<ObservableList<InputValueType>> list;

  /// The result if the condition is true
  final Getter<ReturnValueType>? Function(Getter<InputValueType> element) each;

  /// Triggered any time there is a new value
  final Event onAfterChange = Event();

  /// Compute the value
  ObservableList<ReturnValueType> getValue() {
    ObservableList<ReturnValueType> returnList = ObservableList();
    for (Getter<InputValueType> inputElement in list.value) {
      Getter<ReturnValueType>? returnElement = each(inputElement);
      if (returnElement != null) {
        returnList.add(returnElement);
      }
    }
    return returnList;
  }

  /// Compute the value
  ObservableList<ReturnValueType> get value => getValue();

  /// Created a new For computer
  For({
    required this.list,
    required this.each,
  }) {
    this.onAfterChange.subscribeTo(list.onAfterChange);
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
