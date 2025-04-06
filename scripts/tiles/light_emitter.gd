class_name M_LightEmitterTile extends M_AirTile

var _light: M_Light
var _emitter_outputs: Array[M_Light]

static func from_layer(position_: Vector3i, axis: M_Direction) -> M_LightEmitterTile:
	var inst := M_LightEmitterTile.new(position_)
	inst._light = M_Light.new(inst.get_instance_id(), M_Light.M_Color.WHITE, 30)
	inst._emitter_outputs = inst._light_outputs.duplicate()

	# Emit light in both directions on the axis
	inst._emitter_outputs[axis] = inst._light
	inst._emitter_outputs[(axis + 3) % 6] = inst._light
	return inst

func start_recalculate_light_chain() -> void:
	self.tile_manager.set_light(self.position, M_Direction.UP, self._light)
	self.forward_output_diffs(self._emitter_outputs)
