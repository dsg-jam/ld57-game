class_name M_CheckpointTile extends M_Tile

signal checkpoint_reached

func recalculate_light(level: int) -> void:
	var resulting_color: int = M_Light.M_Color.BLACK
	for dir in M_Direction.values():
		var light := self.get_light_from_dir(dir)
		if light.is_black():
			# We can ignore this light
			continue
		resulting_color |= light.color

	var new_outputs := self._light_outputs.duplicate()

	if resulting_color != M_Light.M_Color.WHITE:
		# We night WHITE to complete the checkpoint!
		self.forward_output_diffs(level, new_outputs)
		return

	new_outputs[M_Direction.DOWN] = M_Light.new(self.get_instance_id(), M_Light.M_Color.WHITE)
	self.forward_output_diffs(level, new_outputs)
	checkpoint_reached.emit()

func update_tile_display() -> void:
	var active := false
	for light in self._light_outputs:
		if light.is_black(): continue
		active = true
		break
	self.tile_manager.set_checkpoint_active(self.position, active)
