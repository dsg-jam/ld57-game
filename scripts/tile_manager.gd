class_name M_TileManager extends Node

@export var _wall_layer: HexagonTileMapLayer
@export var _light_layer: HexagonTileMapLayer
@export var _item_layer: HexagonTileMapLayer
@export var _event_layer: HexagonTileMapLayer
@export var _lights_source_id: int

signal checkpoint_reached

var _tiles: Dictionary[Vector3i, M_Tile]

func _ready() -> void:
	self._load_tiles_from_layers()

func _add_tile(tile: M_Tile) -> M_Tile:
	var existing_tile: M_Tile = self._tiles.get(tile.position)
	if existing_tile:
		self.remove_child(existing_tile)
		existing_tile.tile_manager = null

	self._tiles[tile.position] = tile
	tile.tile_manager = self
	self.add_child(tile)
	return tile

func _load_tiles_from_layers() -> void:
	# Load walls
	for map_pos in self._wall_layer.get_used_cells():
		var cube_pos := self._wall_layer.map_to_cube(map_pos)
		self._add_tile(M_WallTile.new(cube_pos))

	# Load pre-defined items
	for map_pos in self._item_layer.get_used_cells():
		var cube_pos := self._item_layer.map_to_cube(map_pos)
		var atlas_coords := self._item_layer.get_cell_atlas_coords(map_pos)
		# The x component of the atlas coords corresponds to the direction enum
		var direction := atlas_coords.x as M_Tile.M_Direction
		self._add_tile(M_MirrorTile.new(cube_pos, direction))

	# Load events
	for map_pos in self._event_layer.get_used_cells():
		var cube_pos := self._event_layer.map_to_cube(map_pos)
		var event_tile = M_EventTile.new(cube_pos)
		event_tile.checkpoint_reached.connect(self._on_checkpoint_reached)
		self._add_tile(event_tile)

	# Load light emitters
	for map_pos in self._light_layer.get_used_cells():
		var cube_pos := self._light_layer.map_to_cube(map_pos)
		var atlas_coords := self._item_layer.get_cell_atlas_coords(map_pos)
		# The x component of the atlas coords corresponds to the direction enum
		var direction := atlas_coords.x as M_Tile.M_Direction
		self._add_tile(M_LightEmitterTile.from_layer(cube_pos, direction))

	self._recalculate_light()

func _on_checkpoint_reached(pos: Vector3i):
	var map_pos = self._event_layer.cube_to_map(pos)
	checkpoint_reached.emit(map_pos.y)

func set_item(item_type: Global.ItemType) -> bool:
	var cube_pos = self._item_layer.get_closest_cell_from_mouse()
	var existing_tile: M_Tile = self._tiles.get(cube_pos)
	if existing_tile and not existing_tile is M_AirTile:
		return false

	var map_pos = self._item_layer.cube_to_map(cube_pos)
	var new_tile: M_Tile
	match item_type:
		Global.ItemType.MIRROR:
			new_tile = M_MirrorTile.new(cube_pos, M_Tile.M_Direction.UP_RIGHT)
		_:
			push_error("Unhandled item")
			return false
	self._add_tile(new_tile)
	self._item_layer.set_cell(map_pos, 0, Vector2i(0, 0))
	self._recalculate_light()
	return true

func remove_item() -> Global.ItemType:
	var cube_pos = self._item_layer.get_closest_cell_from_mouse()
	var tile = self._tiles.get(cube_pos)
	if not tile: return Global.ItemType.NONE
	# TODO: Expand with other variants
	if not tile is M_MirrorTile: return Global.ItemType.NONE

	var map_pos = self._item_layer.cube_to_map(cube_pos)
	# TODO: erase tile
	self._tiles.erase(cube_pos)
	self._item_layer.erase_cell(map_pos)
	var item_type = Global.ItemType.NONE
	if tile is M_MirrorTile:
		item_type = Global.ItemType.MIRROR
	return item_type

func rotate_item() -> bool:
	var cube_pos = self._item_layer.get_closest_cell_from_mouse()
	var tile: M_Tile = self._tiles.get(cube_pos)
	if not (tile and tile is M_MirrorTile): return false
	var map_pos = self._item_layer.cube_to_map(cube_pos)

	tile.rotate_clockwise()
	var a = tile._normal_dir
	self._item_layer.set_cell(map_pos, 0, Vector2i(a, 0))
	self._recalculate_light()
	return true

func get_tile(position: Vector3i) -> M_Tile:
	var tile: M_Tile = self._tiles.get(position)
	if not tile:
		if position.distance_to(Vector3i.ZERO) > 100:
			# SAFETY: prevent the light from propagating too far
			push_warning("Tile propagation stopped due to distance from ZERO")
			return null
		# fill with air
		tile = self._add_tile(M_AirTile.new(position))
	return tile

func _recalculate_light() -> void:
	self._light_layer.clear()
	for pos in self._tiles:
		var tile := self._tiles[pos]
		if tile is M_LightEmitterTile:
			print("Starting light output from: ", tile.position)
			tile.recalculate_light()

func set_light(position: Vector3i, direction: M_Tile.M_Direction, _light: M_Light) -> void:
	var x_coord = direction % 3
	var map_pos := self._light_layer.cube_to_map(position)
	self._light_layer.set_cell(map_pos, self._lights_source_id, Vector2i(x_coord, 0))
