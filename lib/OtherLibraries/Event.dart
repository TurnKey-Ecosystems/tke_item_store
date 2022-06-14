import 'dart:developer';

abstract class _EventTriggerWrapper {
  bool get isProcessingTrigger;
  void call(List<Function?> listeners, bool tempShouldLog);
}

class _EventTriggerWrapperUnchanging implements _EventTriggerWrapper {
  final bool isProcessingTrigger;
  void call(List<Function?> listeners, bool tempShouldLog) {}
  const _EventTriggerWrapperUnchanging() : isProcessingTrigger = false;
}

class _EventTriggerWrapperChanging implements _EventTriggerWrapper {
  int _triggerCount = 0;
  bool get isProcessingTrigger => _triggerCount > 0;
  void call(List<Function?> listeners, bool tempShouldLog) {
    _triggerCount++;
    int nullListenerCount = 0;
    for (Function? listener in listeners) {
      if (tempShouldLog) {
        print('Triggering listener ${listener?.hashCode};');
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
  final bool tempShouldLog;

  Event({this.tempShouldLog = false})
      : listeners = [],
        listenersIsModifiable = true,
        _trigger = _EventTriggerWrapperChanging();

  const Event.unchanging()
      : listeners = const [],
        listenersIsModifiable = false,
        tempShouldLog = false,
        _trigger = const _EventTriggerWrapperUnchanging();

  Future<void> addListener(Function? listener, {Event? removalTrigger}) async {
    removalTrigger?.addListener(() {
      this.removeListener(listener);
    });
    await _when(() => _trigger.isProcessingTrigger == false);
    if (listener != null && listenersIsModifiable) {
      listeners.add(listener);
    }
  }

  Future<void> removeListener(Function? listener) async {
    await _when(() => _trigger.isProcessingTrigger == false);
    if (listenersIsModifiable) {
      listeners.remove(listener);
    }
  }

  void trigger() {
    _trigger(listeners, tempShouldLog);
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
