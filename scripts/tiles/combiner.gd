class_name M_CombinerTile extends M_Tile

var _normal_dir: M_Direction
# normal_dir is also the output of the combiner
var _input_dirs: Array[M_Direction]

func _init(position_: Vector3i, normal_dir_: M_Direction) -> void:
	super (position_)
	self.item_type = Global.ItemType.COMBINER
	self._normal_dir = normal_dir_
	self._update_mapping()

func rotate_clockwise() -> M_Direction:
	self._normal_dir = ((self._normal_dir + 1) % 6) as M_Direction
	self._update_mapping()
	return self._normal_dir

func _update_mapping() -> void:
	self._input_dirs.clear()
	var input_dir := posmod(self._normal_dir + 3, 6) as M_Direction
	for off in [-1, 0, 1]:
		var dir := posmod(input_dir + off, 6) as M_Direction
		self._input_dirs.push_back(dir)

func recalculate_light(level: int) -> void:
	var output_light := M_Light.black()
	for input_dir in self._input_dirs:
		var light := self.get_light_from_dir(input_dir)
		if light.is_black(): continue
		output_light = M_Light.combine(output_light, light)

	var new_outputs := self._light_outputs.duplicate()
	new_outputs[self._normal_dir] = output_light
	print(self, ": emitting: ", output_light)

	self.tile_manager.set_light(self.position, self._normal_dir, output_light)
	self.forward_output_diffs(level, new_outputs)

func update_tile_display() -> void:
	var light := self._light_outputs[self._normal_dir]
	self.tile_manager.set_light(self._position, self._normal_dir, light)
