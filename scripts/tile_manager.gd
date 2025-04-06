class_name M_TileManager extends Node

@export var _wall_layer: HexagonTileMapLayer
@export var _light_layer: HexagonTileMapLayer
@export var _mirror_layer: HexagonTileMapLayer

var _tiles: Dictionary[Vector3i, M_Tile]

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
	var lights_to_propagate: Array[M_Tile] = []
	for map_pos in self._light_layer.get_used_cells():
		var cube_pos := self._light_layer.map_to_cube(map_pos)
		var atlas_coords := self._light_layer.get_cell_atlas_coords(map_pos)
		if atlas_coords.y == 1:
			# hard-coded coords for mirrors
			print("mirror at ", map_pos)
			self._add_tile(M_MirrorTile.new(cube_pos, M_Tile.DOWN_LEFT))
			continue

		var tile := self._add_tile(M_AirTile.new(cube_pos))
		lights_to_propagate.push_back(tile)

	for tile in lights_to_propagate:
		# start a propagation
		var cube_pos_top := tile.position + M_Tile.UP
		var tile_top := self._add_tile(M_AirTile.new(cube_pos_top))

		print("Starting propagation on ", tile.position)
		tile.on_incoming_light(tile_top, M_Light.new(M_Light.M_Color.WHITE, 30))

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

func set_light(position: Vector3i, direction: Vector3i, _light: M_Light) -> void:
	var x_coord = 0
	match direction:
		M_Tile.UP:
			x_coord = 0
		M_Tile.UP_RIGHT:
			x_coord = 1
		M_Tile.DOWN_RIGHT:
			x_coord = 2
		M_Tile.DOWN:
			x_coord = 3
		M_Tile.DOWN_LEFT:
			x_coord = 4
		M_Tile.UP_LEFT:
			x_coord = 5

	var map_pos := self._light_layer.cube_to_map(position)
	self._light_layer.set_cell(map_pos, 0, Vector2i(x_coord, 0))
