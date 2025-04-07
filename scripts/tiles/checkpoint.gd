class_name M_CheckpointTile extends M_Tile

signal checkpoint_reached

func recalculate_light() -> void:
	var resulting_color := M_Light.M_Color.BLACK
	for dir in M_Direction.values():
		var light := self.get_light_from_dir(dir)
		if light.is_black():
			# We can ignore this light
			continue
		resulting_color |= light.color

	var new_outputs := self._light_outputs.duplicate()
	new_outputs.fill(M_Light.black())

	if resulting_color != M_Light.M_Color.WHITE:
		# We night WHITE to complete the checkpoint!
		self.forward_output_diffs(new_outputs)
		return

	new_outputs[M_Direction.DOWN] = M_Light.new(self.get_instance_id(), M_Light.M_Color.WHITE)
	self.forward_output_diffs(new_outputs)
	checkpoint_reached.emit()
