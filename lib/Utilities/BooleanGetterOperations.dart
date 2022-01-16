part of tke_item_store;

Getter<bool> areEqual<ValueType>(Getter<ValueType> getterA, Getter<ValueType> getterB) => Computed(
  () => getterA.value == getterB.value,
  recomputeTriggers: [
    getterA.onAfterChange,
    getterB.onAfterChange,
  ],
);

Getter<bool> areNotEqual<ValueType>(Getter<ValueType> getterA, Getter<ValueType> getterB) => Computed(
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