part of tke_item_store;

/// Defines an observable version of a list
class ObservableList<ElementType> implements Iterable<Getter<ElementType>> {
  /// This is the list that is being wrapped
  final List<Getter<ElementType>> _elements;

  /// This is fired when the contents of the list change
  final Event onContentChanged;

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
    _elements[index] = element;
    onContentChanged.trigger();
  }

  /// Add an element to the list
  void add(Getter<ElementType> element) {
    _elements.add(element);
    onContentChanged.trigger();
  }

  /// Add a list of elements to the list
  void addAll(Iterable<Getter<ElementType>> elements) {
    _elements.addAll(elements);
    onContentChanged.trigger();
  }

  /// Remove an element from the list
  void remove(Getter<ElementType> element) {
    _elements.remove(element);
    onContentChanged.trigger();
  }

  /// Create a new list
  ObservableList()
      : _elements = [],
        onContentChanged = Event();

  /// Create a new list from a dart list
  ObservableList.fromList(List<Getter<ElementType>> list)
      : _elements = list,
        onContentChanged = Event();

  /// Create an unchanging observable list
  const ObservableList.constList(List<Getter<ElementType>> list)
      : _elements = list,
        onContentChanged = const Event.unchanging();

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
    return List.from(_elements);
  }

  @override
  Set<Getter<ElementType>> toSet() {
    return Set.from(_elements);
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
