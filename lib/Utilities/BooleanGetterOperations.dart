part of tke_item_store;

Getter<bool> areEqual<ValueTypeA, ValueTypeB>(
        Getter<ValueTypeA> getterA, Getter<ValueTypeB> getterB) =>
    Computed(
      () => getterA.value == getterB.value,
      recomputeTriggers: [
        getterA.onAfterChange,
        getterB.onAfterChange,
      ],
    );

Getter<bool> areNotEqual<ValueTypeA, ValueTypeB>(
        Getter<ValueTypeA> getterA, Getter<ValueTypeB> getterB) =>
    Computed(
      () => getterA.value != getterB.value,
      recomputeTriggers: [
        getterA.onAfterChange,
        getterB.onAfterChange,
      ],
    );

Getter<bool> not(Getter<bool> getter) => Computed(
      () => !getter.value,
      recomputeTriggers: [
        getter.onAfterChange,
      ],
    );

Getter<bool> qq(Getter<bool?> getterA, Getter<bool> getterB) => Computed(
      () => getterA.value ?? getterB.value,
      recomputeTriggers: [
        getterA.onAfterChange,
        getterB.onAfterChange,
      ],
    );
