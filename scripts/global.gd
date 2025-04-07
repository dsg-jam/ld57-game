extends Node

enum ItemType {
	NONE     = -1,
	MIRROR   = 0,
	SPLITTER = 1,
	COMBINER = 2,
}

const ALL_ITEM_TYPES: Array[ItemType] = [
	ItemType.MIRROR,
	ItemType.SPLITTER,
	ItemType.COMBINER,
]

const ItemTypeToName: Dictionary[ItemType, String] = {
	ItemType.NONE: "NONE",
	ItemType.MIRROR: "Mirror",
	ItemType.SPLITTER: "Splitter",
	ItemType.COMBINER: "Combiner"
}
