class_name M_TileManager extends Node

@export var _wall_layer: HexagonTileMapLayer
@export var _light_layer: HexagonTileMapLayer
@export var _item_layer: HexagonTileMapLayer
@export var _event_layer: HexagonTileMapLayer
@export var _lights_source_id: int

signal checkpoint_reached

var _tiles: Dictionary[Vector3i, M_Tile]
var _checkpoints: Array[float]
var _next_checkpoint = 0

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
		match atlas_coords.y:
			0: self._add_tile(M_MirrorTile.new(cube_pos, direction))
			1: self._add_tile(M_SplitterTile.new(cube_pos, direction))
			2: self._add_tile(M_CombinerTile.new(cube_pos, direction))

	# Load events
	for map_pos in self._event_layer.get_used_cells():
		var cube_pos := self._event_layer.map_to_cube(map_pos)
		var event_tile = M_EventTile.new(cube_pos)
		event_tile.checkpoint_reached.connect(self._on_checkpoint_reached)
		self._checkpoints.push_back(_event_layer.cube_to_local(cube_pos).y)
		self._add_tile(event_tile)
	self._checkpoints.sort()
	self._on_checkpoint_reached()

	# Load light emitters
	for map_pos in self._light_layer.get_used_cells():
		var atlas_coords := self._light_layer.get_cell_atlas_coords(map_pos)
		if atlas_coords.x > 3:
			# Only the first three tiles can be emitters
			continue
		var cube_pos := self._light_layer.map_to_cube(map_pos)
		# The x component of the atlas coords corresponds to the direction enum
		var axis := atlas_coords.x as M_Tile.M_Direction
		var color := (atlas_coords.y + 1) as M_Light.M_Color
		self._add_tile(M_LightEmitterTile.new(cube_pos, color, axis))

	self._recalculate_light()

func _on_checkpoint_reached():
	if self._next_checkpoint >= len(self._checkpoints):
		return
	var y := self._checkpoints[self._next_checkpoint]
	self._next_checkpoint += 1
	checkpoint_reached.emit(y)

func set_item(item_type: Global.ItemType) -> bool:
	var cube_pos = self._item_layer.get_closest_cell_from_mouse()
	var existing_tile: M_Tile = self._tiles.get(cube_pos)
	if existing_tile and not existing_tile is M_AirTile:
		return false

	var map_pos = self._item_layer.cube_to_map(cube_pos)
	var new_tile: M_Tile
	var atlas_y: int
	match item_type:
		Global.ItemType.MIRROR:
			new_tile = self._add_tile(M_MirrorTile.new(cube_pos, M_Tile.M_Direction.UP_RIGHT))
			atlas_y = 0
		Global.ItemType.SPLITTER:
			new_tile = self._add_tile(M_SplitterTile.new(cube_pos, M_Tile.M_Direction.UP_RIGHT))
			atlas_y = 1
		Global.ItemType.COMBINER:
			new_tile = self._add_tile(M_CombinerTile.new(cube_pos, M_Tile.M_Direction.UP_RIGHT))
			atlas_y = 2
		_:
			push_error("Unhandled item")
			return false

	new_tile.placed_by_user = true
	self._item_layer.set_cell(map_pos, 0, Vector2i(0, atlas_y))
	self._recalculate_light()
	return true

func remove_item() -> Global.ItemType:
	var cube_pos := self._item_layer.get_closest_cell_from_mouse()
	var tile: M_Tile = self._tiles.get(cube_pos)
	if not (tile and tile.placed_by_user): return Global.ItemType.NONE

	var map_pos := self._item_layer.cube_to_map(cube_pos)
	# TODO: erase tile
	self._tiles.erase(cube_pos)
	self._item_layer.erase_cell(map_pos)
	self._recalculate_light()
	return tile.item_type

func rotate_item() -> bool:
	var cube_pos := self._item_layer.get_closest_cell_from_mouse()
	var tile: M_Tile = self._tiles.get(cube_pos)
	if not (tile and tile.placed_by_user): return false

	var map_pos = self._item_layer.cube_to_map(cube_pos)
	var atlas_x: M_Tile.M_Direction = tile.rotate_clockwise()
	var atlas_y := self._item_layer.get_cell_atlas_coords(map_pos).y
	self._item_layer.set_cell(map_pos, 0, Vector2i(atlas_x, atlas_y))
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
	for tile_ in self._tiles.values():
		var tile: M_Tile = tile_
		tile.reset_light_calculation()

	self._light_layer.clear()
	for tile in self._tiles.values():
		if tile is M_LightEmitterTile:
			tile.start_recalculate_light_chain()

func set_light(position: Vector3i, direction: M_Tile.M_Direction, light: M_Light) -> void:
	var map_pos := self._light_layer.cube_to_map(position)
	if light.is_black():
		self._light_layer.erase_cell(map_pos)
		return

	# The x axis is for the cardinal directions and the
	# y axis contains the various colours in the same order as the bitfield.
	var atlas_coords := Vector2i(direction % 3, light.color - 1)
	self._light_layer.set_cell(map_pos, self._lights_source_id, atlas_coords)
