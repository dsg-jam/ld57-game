class_name M_AirTile extends M_Tile

var _light_rays: Dictionary[Direction, M_Light]

func _update_self(direction: Direction, light: M_Light) -> void:
	self._light_rays[direction] = light
	self.tile_manager.set_light(self._position, direction, light)

func on_incoming_light(source: M_Tile, light: M_Light) -> void:
	var dir_vec := self._position - source.position
	var dir := vec_to_direction(dir_vec)
	self._update_self(dir, light)
	var tile := self.tile_manager.get_tile(self._position + dir_vec)
	if not tile:
		return
	tile.on_incoming_light(self, light.weaken())
