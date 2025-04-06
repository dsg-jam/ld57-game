class_name M_LightEmitterTile extends M_Tile

static func from_layer(position_: Vector3i, dir: M_Direction) -> M_LightEmitterTile:
	var inst := M_LightEmitterTile.new(position_)
	var light := M_Light.new(M_Light.M_Color.WHITE, 30)

	# Emit light in both directions
	inst._light_outputs[dir] = light
	inst._light_outputs[(dir + 3) % 6] = light
	return inst

func recalculate_light() -> void:
	self.tile_manager.set_light(self.position, M_Direction.UP, M_Light.new(M_Light.M_Color.WHITE, 30))
	self.forward_updates_to_outputs()
