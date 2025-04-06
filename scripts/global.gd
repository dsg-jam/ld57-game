extends Node

enum ItemType {
	NONE = -1,
	MIRROR = 0,
}

const ALL_ITEM_TYPES: Array[Global.ItemType] = [Global.ItemType.MIRROR]

const ItemTypeToName: Dictionary[ItemType, String] = {
	ItemType.NONE: "NONE",
	ItemType.MIRROR: "Mirror"
}
