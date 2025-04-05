class_name M_MirrorTile extends M_Tile

var reflection_dir: Vector3i

func _init(position_: Vector3i, reflection_dir_: Vector3i) -> void:
	super (position_)
	self.reflection_dir = reflection_dir_
	if ALL_DIRECTIONS.find(reflection_dir_) == -1:
		push_error("Invalid direction: ", reflection_dir_)

func _reflect_direction(dir: Vector3i) -> Vector3i:
	# I'm sure there's a mathematical way to do this, but I'm too tired to figure it out.
	# TODO: Either complete this list by hand or find a better way to do this.
	match self.reflection_dir:
		DOWN_LEFT:
			match dir:
				DOWN: return DOWN_LEFT
				DOWN_LEFT: return UP
				DOWN_RIGHT: return UP_LEFT
				_: return Vector3i.ZERO
	push_error("Invalid reflect axis: " + str(self.reflect_axis))
	return Vector3i.ZERO

func on_incoming_light(source: M_Tile, light: M_Light) -> void:
	var direction := self._position - source.position
	var new_direction := self._reflect_direction(direction)
	if new_direction == Vector3i.ZERO:
		# Hitting the mirror from the wrong side
		return

	var tile := self.tile_manager.get_tile(self._position + new_direction)
	if not tile:
		return
	tile.on_incoming_light(self, light.weaken())
