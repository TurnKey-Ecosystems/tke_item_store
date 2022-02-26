part of tke_item_store;

/// Returns one of two different values absed on a condition
class For<InputValueType, ReturnValueType>
    implements Getter<ObservableList<ReturnValueType>> {
  /// Register witht he getter store
  late final String getterID = GetterStore.registerWithGetterStore(this);

  /// The condition that will change the result
  final Getter<int> count;

  /// The result if the condition is true
  final Getter<ReturnValueType>? Function(
          Getter<int> index, Getter<ObservableList<ReturnValueType>> outputList)
      each;

  /// Triggered any time there is a new value
  final Event onAfterChange = Event();

  /// Compute the value
  ObservableList<ReturnValueType> getValue() {
    ObservableList<ReturnValueType> returnList = ObservableList();
    for (int i = 0; i < count.value; i++) {
      Getter<ReturnValueType>? returnElement = each(i.g, returnList.g);
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
    required this.count,
    required this.each,
  }) {
    this.onAfterChange.subscribeTo(count.onAfterChange);
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