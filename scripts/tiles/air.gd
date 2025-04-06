class_name M_AirTile extends M_Tile

func recalculate_light() -> void:
	var new_outputs := self._light_outputs.duplicate()
	for dir in M_Direction.values():
		var light := self.get_light_from_dir(dir)
		var opposite_dir: int = (dir + 3) % 6
		new_outputs[opposite_dir] = light
		if not light.is_black():
			# TODO: do this differently!
			self.tile_manager.set_light(self.position, opposite_dir, light)
	self.forward_output_diffs(new_outputs)
