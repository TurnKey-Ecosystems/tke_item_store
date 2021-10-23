import 'dart:developer';
import 'dart:collection' as D_Collections;

class Event {
  final List<Function?> listeners;

  bool get listenersIsModifiable {
    bool isModifiable = true;
    try {
      listeners.add(null);
    } catch (e) {
      isModifiable = false;
    }
    return isModifiable;
  }

  Event() : listeners = [];

  const Event.unchanging() : listeners = const [];

  void addListener(Function? listener) {
    if (listener != null && listenersIsModifiable) {
      listeners.add(listener);
    }
  }

  void removeListener(Function? listener) {
    if (listenersIsModifiable) {
      listeners.remove(listener);
    }
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