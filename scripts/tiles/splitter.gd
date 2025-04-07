class_name M_SplitterTile extends M_Tile

var _normal_dir: M_Direction
# input dir is opposite of the normal dir
var _red_dir: M_Direction
var _green_dir: M_Direction
var _blue_dir: M_Direction

func _init(position_: Vector3i, normal_dir_: M_Direction) -> void:
	super (position_)
	self.item_type = Global.ItemType.SPLITTER
	self._normal_dir = normal_dir_
	self._update_mapping()

func rotate_clockwise() -> M_Direction:
	self._normal_dir = ((self._normal_dir + 1) % 6) as M_Direction
	self._update_mapping()
	return self._normal_dir

func _update_mapping() -> void:
	# green is opposite to the input
	self._green_dir = posmod(self._normal_dir + 3, 6) as M_Direction
	# red is to the left of green
	self._red_dir = posmod(self._green_dir - 1, 6) as M_Direction
	# blue is to the right of green
	self._blue_dir = posmod(self._green_dir + 1, 6) as M_Direction

func recalculate_light() -> void:
	var new_outputs := self._light_outputs.duplicate()
	new_outputs.fill(M_Light.black())
	var light := self.get_light_from_dir(self._normal_dir)
	# TODO: do this differently!
	self.tile_manager.set_light(self.position, self._normal_dir, light)

	new_outputs[self._red_dir] = light.split_red()
	new_outputs[self._green_dir] = light.split_green()
	new_outputs[self._blue_dir] = light.split_blue()
	self.forward_output_diffs(new_outputs)
