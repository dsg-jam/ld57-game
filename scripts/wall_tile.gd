class_name M_WallTile extends M_Tile

func on_incoming_light(_source: M_Tile, _light: M_Light) -> void:
	# A wall just blocks the light
	return
