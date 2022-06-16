import 'dart:developer';

abstract class _EventTriggerWrapper {
  bool get isProcessingTrigger;
  void call(List<Function?> listeners, bool shouldLog);
}

class _EventTriggerWrapperUnchanging implements _EventTriggerWrapper {
  final bool isProcessingTrigger;
  void call(List<Function?> listeners, bool shouldLog) {}
  const _EventTriggerWrapperUnchanging() : isProcessingTrigger = false;
}

class _EventTriggerWrapperChanging implements _EventTriggerWrapper {
  int _triggerCount = 0;
  bool get isProcessingTrigger => _triggerCount > 0;
  void call(List<Function?> listeners, bool shouldLog) {
    _triggerCount++;
    int nullListenerCount = 0;
    int listenerIndex = 0;
    for (Function? listener in listeners) {
      if (shouldLog) {
        print('Event - ${listenerIndex} - About to call ${listener.hashCode}');
      }
      if (listener != null) {
        try {
          listener();
        } catch (e) {
          log(e.toString());
        }
      } else {
        nullListenerCount++;
      }
      if (shouldLog) {
        print('Event - Finished ${listener.hashCode}');
        print('Event - listener count ${listeners.length}');
      }
      listenerIndex++;
    }
    for (; nullListenerCount > 0; nullListenerCount--) {
      listeners.remove(null);
    }
    _triggerCount--;
  }
}

class Event {
  final List<Function?> listeners;
  final _EventTriggerWrapper _trigger;

  final bool listenersIsModifiable;
  final bool shouldLog;

  Event({this.shouldLog = false})
      : listeners = [],
        listenersIsModifiable = true,
        _trigger = _EventTriggerWrapperChanging();

  const Event.unchanging()
      : listeners = const [],
        listenersIsModifiable = false,
        shouldLog = false,
        _trigger = const _EventTriggerWrapperUnchanging();

  void addListener(Function? listener, {Event? removalTrigger}) {
    removalTrigger?.addListener(() {
      this.removeListener(listener);
    });
    if (listener != null && listenersIsModifiable) {
      if (_trigger.isProcessingTrigger) {
        () async {
          await _when(() => _trigger.isProcessingTrigger == false);
          listeners.add(listener);
          listener();
        }();
        print('Delaying adding listener ${listener.hashCode}!');
      } else {
        listeners.add(listener);
      }
      //listeners.add(listener);
    }
  }

  void removeListener(Function? listener) {
    if (listenersIsModifiable) {
      /*if (_trigger.isProcessingTrigger) {
        () async {
          await _when(() => _trigger.isProcessingTrigger == false);
          listeners.remove(listener);
        }();
      } else {
        listeners.remove(listener);
      }*/
      listeners.remove(listener);
    }
  }

  void trigger() {
    _trigger(listeners, shouldLog);
  }

  static Future<void> _when(bool Function() condition) async {
    // Wait until the condition has been met
    while (!condition()) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void subscribeTo(Event event, {Event? removalTrigger}) {
    trigger.subscribeTo(event, removalTrigger: removalTrigger);
  }

  void unsubscribeFrom(Event event) {
    trigger.unsubscribeFrom(event);
  }

  List<Event?> get subscriptions => trigger.subscriptions;
}

extension on Function() {
  void subscribeTo(Event event, {Event? removalTrigger}) {
    _recordSubscription(
      hashcode: this.hashCode,
      event: event,
    );
    event.addListener(this, removalTrigger: removalTrigger);
  }

  void unsubscribeFrom(Event event) {
    event.removeListener(this);
    _subscriptionsByFunctionHashcode[this.hashCode]?.remove(event);
  }

  static Map<int, List<Event?>> _subscriptionsByFunctionHashcode = Map();
  static void _recordSubscription({
    required int hashcode,
    required Event? event,
  }) {
    if (!_subscriptionsByFunctionHashcode.containsKey(hashcode)) {
      _subscriptionsByFunctionHashcode[hashcode] = [];
    }
    _subscriptionsByFunctionHashcode[hashcode]!.add(event);
  }

  List<Event?> get subscriptions =>
      _subscriptionsByFunctionHashcode[this.hashCode] ?? [];
}
