class_name M_LightEmitterTile extends M_AirTile

var _light: M_Light
var _emitter_outputs: Array[M_Light]

func _init(position_: Vector3i, color: M_Light.M_Color, axis: M_Direction) -> void:
	super(position_)
	self._light = M_Light.new(self.get_instance_id(), color, 30)
	self._emitter_outputs = self._light_outputs.duplicate()

	# Emit light in both directions on the axis
	self._emitter_outputs[axis] = self._light
	self._emitter_outputs[(axis + 3) % 6] = self._light


func start_recalculate_light_chain() -> void:
	print(self, ": emitting light: ", self._light)
	self.tile_manager.set_light(self.position, M_Direction.UP, self._light)
	self.forward_output_diffs(self._emitter_outputs)
