extends Node

#@export var _light_layer: HexagonTileMapLayer
@export var _item_container: Node
@export var _tile_manager: M_TileManager

var _item_button_prefab = preload("res://prefabs/hud/item_button.tscn")
var _item_buttons: Dictionary[Global.ItemType, ItemButton]
var _available_items: Dictionary[Global.ItemType, int] = {
	Global.ItemType.MIRROR: 2
}
var _selected_items_type: Global.ItemType = Global.ItemType.NONE

func _ready() -> void:
	self._tile_manager.checkpoint_reached.connect(self._on_checkpoint_reached)
	self._setup_ui()

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		self._place_item(self._selected_items_type)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		# Delete item if applicable
		self._remove_item()
	self._update_counters()

func _setup_ui():
	for item_type in Global.ALL_ITEM_TYPES:
		var item_button: ItemButton = _item_button_prefab.instantiate()
		_item_container.add_child(item_button)
		item_button.setup(item_type)
		item_button.button_pressed.connect(_on_item_button_pressed)
		self._item_buttons.set(item_type, item_button)

func _update_counters():
	for item_type in self._item_buttons.keys():
		self._item_buttons[item_type].update_counter(self._available_items[item_type])

func _consume_item(item_type: Global.ItemType) -> bool:
	if not (item_type in self._available_items):
		self._available_items[item_type] = 0
	if self._available_items[item_type] <= 0:
		return false
	self._available_items[item_type] -= 1
	return true

func _produce_item(item_type: Global.ItemType):
	self._available_items[item_type] += 1

func _place_item(item_type: Global.ItemType):
	self._tile_manager.rotate_item()
	if not self._consume_item(item_type):
		return
	if not self._tile_manager.set_item(item_type):
		self._produce_item(item_type)
		return

func _remove_item():
	var item_type = self._tile_manager.remove_item()
	if item_type == Global.ItemType.NONE:
		return
	self._produce_item(item_type)

# Signal handlers

func _on_item_button_pressed(item_type: Global.ItemType):
	self._selected_items_type = item_type

func _on_checkpoint_reached(y: float):
	print(y)
