class_name M_AirTile extends M_Tile

func recalculate_light(level: int) -> void:
	var new_outputs := self._light_outputs.duplicate()
	for dir in M_Direction.values():
		var light := self.get_light_from_dir(dir)
		var opposite_dir: int = (dir + 3) % 6
		new_outputs[opposite_dir] = M_Light.coalesce(light, new_outputs[opposite_dir])
	self.forward_output_diffs(level, new_outputs)

func update_tile_display() -> void:
	var axis_lights: Array[M_Light]
	axis_lights.resize(3)
	axis_lights.fill(M_Light.black())

	for dir in M_Direction.values():
		var axis = dir % 3
		axis_lights[axis] = M_Light.combine(axis_lights[axis], self._light_outputs[dir])

	for axis in range(axis_lights.size()):
		self.tile_manager.set_light(self._position, axis as M_Direction, axis_lights[axis])
