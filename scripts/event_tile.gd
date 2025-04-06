class_name M_EventTile extends M_Tile

signal checkpoint_reached

func _init(position_: Vector3i) -> void:
	super (position_)

func on_incoming_light(source: M_Tile, light: M_Light) -> void:
	if light.strength <= 0:
		return
	checkpoint_reached.emit(self._position)
