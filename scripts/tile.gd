class_name M_Tile extends Node

const VEC_UP := Vector3i(0, -1, 1)
const VEC_UP_RIGHT := Vector3i(1, -1, 0)
const VEC_DOWN_RIGHT := Vector3i(1, 0, -1)
const VEC_DOWN := Vector3i(0, 1, -1)
const VEC_DOWN_LEFT := Vector3i(-1, 1, 0)
const VEC_UP_LEFT := Vector3i(-1, 0, 1)
# Order must match the Directions enum variants
const ALL_DIRECTION_VECS: Array[Vector3i] = [VEC_UP_RIGHT, VEC_DOWN_RIGHT, VEC_DOWN, VEC_DOWN_LEFT, VEC_UP_LEFT, VEC_UP]

# The order of the variants is guaranteed to correspond with the order in the tilemap.
enum M_Direction {
	UP_RIGHT,
	DOWN_RIGHT,
	DOWN,
	DOWN_LEFT,
	UP_LEFT,
	UP,
}

static func direction_to_vec(dir: M_Direction) -> Vector3i:
	return ALL_DIRECTION_VECS[dir]

static func vec_to_direction(vec: Vector3i) -> M_Direction:
	var idx := ALL_DIRECTION_VECS.find(vec)
	if idx < 0:
		push_error("Invalid direction passed to vec_to_direction: ", vec)
		return M_Direction.UP_RIGHT
	return idx as M_Direction

var tile_manager: M_TileManager

var _position: Vector3i
var position: Vector3i:
	get:
		return self._position
var _light_outputs: Array[M_Light]

func _init(position_: Vector3i) -> void:
	self._position = position_
	self._light_outputs.resize(6)
	self._light_outputs.fill(M_Light.black())

func _class_name() -> String:
	var script = self.get_script()
	if script: return script.get_global_name()
	return "M_Tile"

func _to_string() -> String:
	return "%s%s" % [self._class_name(), self.position]

func get_light_from_dir(dir: M_Direction) -> M_Light:
	var dir_vec := direction_to_vec(dir)
	var tile := self.tile_manager.get_tile(self.position + dir_vec)
	if not tile: return M_Light.black()
	var opposite_dir := (dir + 3) % 6
	return tile.get_light_output_in_dir(opposite_dir).weaken()

func get_light_output_in_dir(dir: M_Direction) -> M_Light:
	return self._light_outputs[dir]

func reset_light_calculation() -> void:
	self._light_outputs.fill(M_Light.black())

func recalculate_light() -> void:
	push_error("recalculate_light() not implemented in " + self._class_name())

func forward_output_diffs(new_outputs: Array[M_Light]) -> bool:
	var triggered_update := false
	for dir in M_Direction.values():
		var old_output := self._light_outputs[dir]
		var new_output := new_outputs[dir]
		if old_output.id == new_output.id:
			#if not (old_output.is_black() and new_output.is_black()):
				#print(self, ": stopped light recursion: ", old_output, " == ", new_output)
			continue
		self._light_outputs[dir] = new_output
		if new_output.is_black():
			continue
		var dir_vec := direction_to_vec(dir)
		var tile := self.tile_manager.get_tile(self.position + dir_vec)
		if not tile: continue
		#print(self, ": forwarding update ", M_Direction.keys()[dir], " to ", tile)
		tile.recalculate_light()
		triggered_update = true
	return triggered_update
