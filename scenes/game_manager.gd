extends Node

@export var _light_layer: HexagonTileMapLayer
@export var _item_container: Node
@export var _item_layer: HexagonTileMapLayer

var _item_button_prefab = preload("res://prefabs/hud/item_button.tscn")
var _available_items: Dictionary[Global.ItemType, int] = {
	Global.ItemType.MIRROR: 2
}
var _selected_items_type: Global.ItemType = Global.ItemType.NONE

class ItemPos:
	var _pos: Vector2i
	var _item_type: Global.ItemType

var _item_positions: Dictionary[Vector2i, Global.ItemType] = {}

func _ready() -> void:
	self._setup_ui()
	
func _process(delta: float) -> void:
	pass

func _input(event):
	var cube_pos = self._item_layer.get_closest_cell_from_mouse()
	var map_pos = self._item_layer.cube_to_map(cube_pos)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		match self._selected_items_type:
			Global.ItemType.NONE:
				# TODO: when tile is an item, rotate it
				pass
			_:
				self._place_item(self._selected_items_type, map_pos)
		self._selected_items_type = Global.ItemType.NONE
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		# Delete item if applicable
		self._remove_item(map_pos)

func _setup_ui():
	for item_type in Global.ALL_ITEM_TYPES:
		var item_button: ItemButton = _item_button_prefab.instantiate()
		_item_container.add_child(item_button)
		item_button.setup(item_type)
		item_button.button_pressed.connect(_on_item_button_pressed)

func _consume_item(item_type: Global.ItemType) -> bool:
	if self._available_items[item_type] <= 0:
		return false
	self._available_items[item_type] -= 1
	return true

func _produce_item(item_type: Global.ItemType):
	self._available_items[item_type] += 1

func _place_item(item_type: Global.ItemType, map_pos: Vector2i):
	if not self._consume_item(item_type):
		print_debug("no more items of this kind")
		return
	if map_pos in self._item_positions.keys():
		print_debug("already occupied")
		return
	self._item_positions.set(map_pos, item_type)
	self._item_layer.set_cell(map_pos, 0, Vector2i(0, 1))

func _remove_item(map_pos: Vector2i):
	if not (map_pos in self._item_positions.keys()):
		print_debug("cell does not contain an item")
		return
	var item_type = self._item_positions[map_pos]
	self._item_positions.erase(map_pos)
	self._produce_item(item_type)
	self._item_layer.erase_cell(map_pos)

# Signal handlers

func _on_item_button_pressed(item_type: Global.ItemType):
	self._selected_items_type = item_type
