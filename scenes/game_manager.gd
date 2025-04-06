extends Node

@export var _light_layer: HexagonTileMapLayer
@export var _item_container: Node
@export var _mirror_layer: HexagonTileMapLayer

var _item_button_prefab = preload("res://prefabs/hud/item_button.tscn")
var _available_items: Dictionary[Global.ItemType, int] = {
	Global.ItemType.MIRROR: 1
}
var _selected_items_type: Global.ItemType = Global.ItemType.NONE

func _ready() -> void:
	self._setup_ui()
	
func _process(delta: float) -> void:
	pass

func _setup_ui():
	for item_type in Global.ALL_ITEM_TYPES:
		var item_button: ItemButton = _item_button_prefab.instantiate()
		_item_container.add_child(item_button)
		item_button.setup(item_type)
		item_button.button_pressed.connect(_on_item_button_pressed)

func _on_item_button_pressed(item_type: Global.ItemType):
	self._selected_items_type = item_type

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cube_pos = self._mirror_layer.get_closest_cell_from_mouse()
		var map_pos = self._mirror_layer.cube_to_map(cube_pos)
		self._mirror_layer.set_cell(map_pos, 0, Vector2i(3,1))
