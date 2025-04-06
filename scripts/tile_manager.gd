class_name M_TileManager extends Node

@export var _wall_layer: HexagonTileMapLayer
@export var _light_layer: HexagonTileMapLayer
@export var _item_layer: HexagonTileMapLayer

var _tiles: Dictionary[Vector3i, M_Tile]

var _item_tiles: Dictionary[Vector3i, M_Tile]

func _ready() -> void:
	self._load_tiles()

func _add_tile(tile: M_Tile) -> M_Tile:
	tile.tile_manager = self
	self.add_child(tile)
	self._tiles[tile.position] = tile
	return tile

func _load_tiles() -> void:
	for map_pos in self._wall_layer.get_used_cells():
		var cube_pos := self._wall_layer.map_to_cube(map_pos)
		self._add_tile(M_WallTile.new(cube_pos))

	# TODO: this is really just hard-coded for demo purposes
	#       we should be able to load this from a file

	for map_pos in self._item_layer.get_used_cells():
		var cube_pos := self._item_layer.map_to_cube(map_pos)
		var atlas_coords := self._item_layer.get_cell_atlas_coords(map_pos)
		# The x component of the atlas coords corresponds to the direction enum
		var direction := atlas_coords.x as M_Tile.Direction
		print("mirror at: ", map_pos, " dir: ", direction)
		self._add_tile(M_MirrorTile.new(cube_pos, direction))

	var lights_to_propagate: Array[M_Tile] = []
	for map_pos in self._light_layer.get_used_cells():
		var cube_pos := self._light_layer.map_to_cube(map_pos)
		var tile := self._add_tile(M_AirTile.new(cube_pos))
		lights_to_propagate.push_back(tile)

	for tile in lights_to_propagate:
		# start a propagation
		var cube_pos_top := tile.position + M_Tile.VEC_UP
		var tile_top := self._add_tile(M_AirTile.new(cube_pos_top))

		print("Starting propagation on ", tile.position)
		tile.on_incoming_light(tile_top, M_Light.new(M_Light.M_Color.WHITE, 30))

func set_item(item_type: Global.ItemType) -> bool:
	var cube_pos = self._item_layer.get_closest_cell_from_mouse()
	var map_pos = self._item_layer.cube_to_map(cube_pos)
	if cube_pos in self._item_tiles.keys():
		print_debug("already occupied")
		return false
	if map_pos in self._wall_layer.get_used_cells():
		print_debug("cell occupied by wall")
		return false
	var item_tile: M_Tile
	match item_type:
		Global.ItemType.MIRROR:
			item_tile = M_MirrorTile.new(cube_pos, M_Tile.Direction.UP_RIGHT)
	self._item_tiles.set(cube_pos, item_tile)
	self._item_layer.set_cell(map_pos, 0, Vector2i(0, 0))
	return true

func remove_item() -> Global.ItemType:
	var cube_pos = self._item_layer.get_closest_cell_from_mouse()
	var map_pos = self._item_layer.cube_to_map(cube_pos)
	if not (cube_pos in self._item_tiles.keys()):
		print_debug("this cell does not contain an item")
		return Global.ItemType.NONE
	var item_tile = self._item_tiles[cube_pos]
	# TODO: erase tile
	self._item_tiles.erase(cube_pos)
	self._item_layer.erase_cell(map_pos)
	var item_type = Global.ItemType.NONE
	if item_tile is M_MirrorTile:
		item_type = Global.ItemType.MIRROR
	return item_type

func rotate_item() -> bool:
	var cube_pos = self._item_layer.get_closest_cell_from_mouse()
	var map_pos = self._item_layer.cube_to_map(cube_pos)
	if not (cube_pos in self._item_tiles.keys()):
		print_debug("this cell does not contain an item")
		return false
	var item_tile = self._item_tiles[cube_pos]
	if item_tile is M_MirrorTile:
		var mirror_tile: M_MirrorTile = item_tile
		mirror_tile.rotate()
		var a = mirror_tile._normal_dir
		self._item_layer.set_cell(map_pos, 0, Vector2i(a, 0))
	else:
		return false
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

func set_light(position: Vector3i, direction: M_Tile.Direction, _light: M_Light) -> void:
	var x_coord = 0
	match direction:
		M_Tile.Direction.UP:
			x_coord = 0
		M_Tile.Direction.UP_RIGHT:
			x_coord = 1
		M_Tile.Direction.DOWN_RIGHT:
			x_coord = 2
		M_Tile.Direction.DOWN:
			x_coord = 3
		M_Tile.Direction.DOWN_LEFT:
			x_coord = 4
		M_Tile.Direction.UP_LEFT:
			x_coord = 5

	var map_pos := self._light_layer.cube_to_map(position)
	self._light_layer.set_cell(map_pos, 0, Vector2i(x_coord, 0))
