part of tke_item_store;

class ${fileBasenameNoExtension} extends Item {
  // Static Properties
  static const String ITEM_TYPE = "${fileBasenameNoExtension}";
  String get itemType { return ITEM_TYPE; }


  // Attributes
  /*final AttributeString someString = AttributeString(
    attributeKey: "someString",
    valueOnCreateNew: "",
    syncDepth: SyncDepth.CLOUD,
  );*/
  /*final AttributeItemSet<SomeItem> someItems = AttributeItemSet(
    attributeKey: "someItems",
    getItemFromItemID: (String itemID) { return SomeItem.fromItemID(itemID); },
    syncDepth: SyncDepth.CLOUD,
    shouldDeleteContentsWhenItemIsDeleted: true,
  );*/


  // Constructors
  ${fileBasenameNoExtension}.createNew() : super.createNew();
  
  ${fileBasenameNoExtension}.fromItemID(String itemID) : super.fromItemID(itemID);



  // Managed by tke-cli DO NOT TOUCH
  static Set<${fileBasenameNoExtension}> get all${fileBasenameNoExtension}Items {
    Set<${fileBasenameNoExtension}> allItemsOfThisType = Set();
    Set<String> itemIDs = AllItemsManager.getItemIDsForItemType(ITEM_TYPE);
    for (String itemID in itemIDs) allItemsOfThisType.add(${fileBasenameNoExtension}.fromItemID(itemID));
    return allItemsOfThisType;
  }

  // Managed by tke-cli DO NOT TOUCH
  static Event get on${fileBasenameNoExtension}CreatedOrDestroyed {
    return AllItemsManager.getOnItemOfTypeCreatedOrDestroyedEvent(itemType: ITEM_TYPE);
  }

  // Managed by tke-cli DO NOT TOUCH
  List<Attribute> getAllAttributes() {
    return [];
  }
}