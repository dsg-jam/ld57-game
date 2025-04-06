class_name M_AirTile extends M_Tile

func recalculate_light() -> void:
	self._light_outputs.fill(M_Light.black())
	for dir in M_Direction.values():
		var light := self.get_light_from_dir(dir)
		if light.is_black():
			# We can ignore this light
			continue
		var opposite_dir: int = (dir + 3) % 6
		self._light_outputs[opposite_dir] = light
		self.tile_manager.set_light(self.position, opposite_dir, light)
	self.forward_updates_to_outputs()
