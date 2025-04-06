class_name M_EventTile extends M_Tile

signal checkpoint_reached

func recalculate_light() -> void:
	for dir in M_Direction.values():
		var light := self.get_light_from_dir(dir)
		if light.is_black():
			# We can ignore this light
			continue
		checkpoint_reached.emit(self._position)
		return
