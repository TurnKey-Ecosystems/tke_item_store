import 'dart:developer';

class Event {
  final List<Function?> listeners;

  Event() : listeners = [];

  const Event.unchanging() : listeners = const [];

  void addListener(Function? listener) {
    if (listener != null) {
      listeners.add(listener);
    }
  }

  void removeListener(Function? listener) {
    listeners.remove(listener);
  }

  void trigger() {
    int nullListenerCount = 0;
    for (Function? listener in listeners) {
      if (listener != null) {
        try {
          listener();
        } catch(e) {
          log(e.toString());
        }
      } else {
        nullListenerCount++;
      }
    }
    for (; nullListenerCount > 0; nullListenerCount--) {
      removeListener(null);
    }
  }
}