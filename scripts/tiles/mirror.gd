class_name M_MirrorTile extends M_Tile

var _normal_dir: M_Direction
var _reflection_mapping: Dictionary[M_Direction, M_Direction]

func _init(position_: Vector3i, normal_dir_: M_Direction) -> void:
	super (position_)
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

func recalculate_light() -> void:
	var new_outputs := self._light_outputs.duplicate()
	for dir in self._reflection_mapping:
		var light := self.get_light_from_dir(dir)
		if light.is_black(): continue
		var out_dir := self._reflection_mapping[dir]
		new_outputs[out_dir] = light
		if not light.is_black():
			# TODO: do this differently!
			self.tile_manager.set_light(self.position, out_dir, light)
	self.forward_output_diffs(new_outputs)
