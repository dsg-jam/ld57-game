class_name M_AirTile extends M_Tile

var _light_rays: Dictionary[Vector3i, M_Light]

func _update_self(direction: Vector3i, light: M_Light) -> void:
	self._light_rays[direction] = light
	self.tile_manager.set_light(self._position, direction, light)

func on_incoming_light(source: M_Tile, light: M_Light) -> void:
	var direction := self._position - source.position
	self._update_self(direction, light)
	var tile := self.tile_manager.get_tile(self._position + direction)
	if not tile:
		return
	tile.on_incoming_light(self, light.weaken())
