part of tke_item_store;

/// Converts normal lists into observable lists
extension ToObservableList<ElementType> on List<Getter<ElementType>> {
  /// Convert the list into a variable version of an observable list
  Value<ObservableList<ElementType>> get v {
    return Value.ofNewVariable(
      ObservableList(source: this),
    );
  }

  /// Convert the list into a getter version of an observable list
  Getter<ObservableList<ElementType>> get g {
    return Getter.ofNewVariable(
      ObservableList(source: this),
    );
  }
}

extension Temp<ElementType> on Getter<ObservableList<ElementType>> {
  Getter<ObservableList<ElementType>> operator +(
      Getter<ObservableList<ElementType>> other) {
    return Computed(
      () {
        ObservableList<ElementType> newList = ObservableList();
        for (Getter<ElementType> element in this.value) {
          newList.add(element);
        }
        for (Getter<ElementType> element in other.value) {
          newList.add(element);
        }
        return newList;
      },
      recomputeTriggers: [
        this.onAfterChange,
        this.value.onElementAddedOrRemoved,
        other.onAfterChange,
        other.value.onElementAddedOrRemoved,
      ],
    );
  }
}

/// Defines an observable version of a list
class ObservableList<ElementType> implements Iterable<Getter<ElementType>> {
  /// This is the list that is being wrapped
  final List<Getter<ElementType>> _elements;

  /// This is fired when an element is added to or removed from the list
  final Event onElementAddedOrRemoved;

  /// This is fired when any of the elements fires its on change event
  final Event onAnyElementsChangeEventTriggered;

  /// Sets up a onAnyElementsChangeEventTriggered event from a source list
  static Event buildOnAnyElementsChangeEventTriggeredFromSource<ElementType>(
      Iterable<Getter<ElementType>> source) {
    Event newEvent = Event();
    for (Getter<ElementType> element in source) {
      element.onAfterChange.addListener(newEvent.trigger);
    }
    return newEvent;
  }

  /// Get the element at the given index
  Getter<ElementType>? operator [](int index) {
    if (_elements.length > index) {
      return _elements[index];
    } else {
      return null;
    }
  }

  /// Overwrite the element at the given index
  void operator []=(int index, Getter<ElementType> element) {
    _elements[index]
        .onAfterChange
        .removeListener(onAnyElementsChangeEventTriggered.trigger);
    _elements[index] = element;
    element.onAfterChange
        .addListener(onAnyElementsChangeEventTriggered.trigger);
    onElementAddedOrRemoved.trigger();
  }

  /// Add an element to the list
  void add(Getter<ElementType> element) {
    _elements.add(element);
    element.onAfterChange
        .addListener(onAnyElementsChangeEventTriggered.trigger);
    onElementAddedOrRemoved.trigger();
  }

  /// Add a list of elements to the list
  void addAll(Iterable<Getter<ElementType>> elements) {
    for (Getter<ElementType> element in elements) {
      _elements.add(element);
      element.onAfterChange
          .addListener(onAnyElementsChangeEventTriggered.trigger);
    }
    onElementAddedOrRemoved.trigger();
  }

  /// Remove an element from the list
  void remove(Getter<ElementType> element) {
    _elements
        .firstWhere(
            (Getter<ElementType> elementToCheck) => element == elementToCheck)
        .onAfterChange
        .removeListener(onAnyElementsChangeEventTriggered.trigger);
    _elements.remove(element);
    onElementAddedOrRemoved.trigger();
  }

  /// Create a new list
  ObservableList({Iterable<Getter<ElementType>> source = const []})
      : _elements = List.from(source),
        onElementAddedOrRemoved = Event(),
        onAnyElementsChangeEventTriggered =
            buildOnAnyElementsChangeEventTriggeredFromSource(source);

  /// Create an unchanging observable list
  const ObservableList.constList()
      : _elements = const [],
        onElementAddedOrRemoved = const Event.unchanging(),
        onAnyElementsChangeEventTriggered = const Event.unchanging();

  @override
  bool any(bool Function(Getter<ElementType> element) test) {
    return _elements.any(test);
  }

  @override
  Iterable<R> cast<R>() {
    return _elements.cast<R>();
  }

  @override
  bool contains(Object? element) {
    return _elements.contains(element);
  }

  @override
  Getter<ElementType> elementAt(int index) {
    return _elements.elementAt(index);
  }

  @override
  bool every(bool Function(Getter<ElementType> element) test) {
    return _elements.every(test);
  }

  @override
  Iterable<T> expand<T>(
      Iterable<T> Function(Getter<ElementType> element) toElements) {
    return _elements.expand<T>(toElements);
  }

  @override
  // TODO: implement first
  Getter<ElementType> get first => _elements.first;

  @override
  Getter<ElementType> firstWhere(
      bool Function(Getter<ElementType> element) test,
      {Getter<ElementType> Function()? orElse}) {
    return _elements.firstWhere(test, orElse: orElse);
  }

  @override
  T fold<T>(T initialValue,
      T Function(T previousValue, Getter<ElementType> element) combine) {
    return _elements.fold<T>(initialValue, combine);
  }

  @override
  Iterable<Getter<ElementType>> followedBy(
      Iterable<Getter<ElementType>> other) {
    return _elements.followedBy(other);
  }

  @override
  void forEach(void Function(Getter<ElementType> element) action) {
    return _elements.forEach(action);
  }

  @override
  // TODO: implement isEmpty
  bool get isEmpty => _elements.isEmpty;

  @override
  // TODO: implement isNotEmpty
  bool get isNotEmpty => _elements.isNotEmpty;

  @override
  // TODO: implement iterator
  Iterator<Getter<ElementType>> get iterator => _elements.iterator;

  @override
  String join([String separator = ""]) {
    return _elements.join(separator);
  }

  @override
  // TODO: implement last
  Getter<ElementType> get last => _elements.last;

  @override
  Getter<ElementType> lastWhere(bool Function(Getter<ElementType> element) test,
      {Getter<ElementType> Function()? orElse}) {
    return _elements.lastWhere(test, orElse: orElse);
  }

  @override
  // TODO: implement length
  int get length => _elements.length;

  @override
  Iterable<T> map<T>(T Function(Getter<ElementType> e) toElement) {
    return _elements.map<T>(toElement);
  }

  @override
  Getter<ElementType> reduce(
      Getter<ElementType> Function(
              Getter<ElementType> value, Getter<ElementType> element)
          combine) {
    return _elements.reduce(combine);
  }

  @override
  // TODO: implement single
  Getter<ElementType> get single => _elements.single;

  @override
  Getter<ElementType> singleWhere(
      bool Function(Getter<ElementType> element) test,
      {Getter<ElementType> Function()? orElse}) {
    return _elements.singleWhere(test, orElse: orElse);
  }

  @override
  Iterable<Getter<ElementType>> skip(int count) {
    return _elements.skip(count);
  }

  @override
  Iterable<Getter<ElementType>> skipWhile(
      bool Function(Getter<ElementType> value) test) {
    return _elements.skipWhile(test);
  }

  @override
  Iterable<Getter<ElementType>> take(int count) {
    return _elements.take(count);
  }

  @override
  Iterable<Getter<ElementType>> takeWhile(
      bool Function(Getter<ElementType> value) test) {
    return _elements.takeWhile(test);
  }

  @override
  List<Getter<ElementType>> toList({bool growable = true}) {
    return _elements.toList(growable: growable);
  }

  @override
  Set<Getter<ElementType>> toSet() {
    return _elements.toSet();
  }

  @override
  Iterable<Getter<ElementType>> where(
      bool Function(Getter<ElementType> element) test) {
    return _elements.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return _elements.whereType<T>();
  }
}
