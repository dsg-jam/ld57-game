class_name M_MirrorTile extends M_Tile

var _normal_dir: M_Direction
var _reflection_mapping: Dictionary[M_Direction, M_Direction]
var _reflection_mapping_inv: Dictionary[M_Direction, M_Direction]

func _init(position_: Vector3i, normal_dir_: M_Direction) -> void:
	super (position_)
	self.item_type = Global.ItemType.MIRROR
	self._normal_dir = normal_dir_
	self._update_reflection_mapping()

func rotate_clockwise() -> M_Direction:
	self._normal_dir = ((self._normal_dir + 1) % 6) as M_Direction
	self._update_reflection_mapping()
	return self._normal_dir

func _update_reflection_mapping() -> void:
	var relative := { -1: 1, 0: 0, 1: -1 }
	self._reflection_mapping.clear()
	for dir_off in relative:
		var src_dir := posmod(self._normal_dir + dir_off, 6) as M_Direction
		var target_dir := posmod(self._normal_dir + relative[dir_off], 6) as M_Direction
		self._reflection_mapping[src_dir] = target_dir
		self._reflection_mapping_inv[target_dir] = src_dir

func recalculate_light(level: int) -> void:
	var new_outputs := self._light_outputs.duplicate()
	for dir in self._reflection_mapping:
		var light := self.get_light_from_dir(dir)
		if light.is_black(): continue
		var out_dir := self._reflection_mapping[dir]
		new_outputs[out_dir] = light
	self.forward_output_diffs(level, new_outputs)

func update_tile_display() -> void:
	var axis_lights: Array[M_Light]
	axis_lights.resize(3)
	axis_lights.fill(M_Light.black())

	for out_dir in self._reflection_mapping_inv:
		var inp_dir := self._reflection_mapping_inv[out_dir]
		var out_axis: int = out_dir % 3
		var light := self._light_outputs[out_dir]
		axis_lights[out_axis] = M_Light.combine(axis_lights[out_axis], light)
		var inp_axis := inp_dir % 3
		if out_axis != inp_axis:
			axis_lights[inp_axis] = M_Light.combine(axis_lights[inp_axis], light)

	for axis in range(axis_lights.size()):
		self.tile_manager.set_light(self._position, axis as M_Direction, axis_lights[axis])
