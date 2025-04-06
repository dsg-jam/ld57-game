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
enum Direction {
	UP_RIGHT,
	DOWN_RIGHT,
	DOWN,
	DOWN_LEFT,
	UP_LEFT,
	UP,
}

static func direction_to_vec(dir: Direction) -> Vector3i:
	return ALL_DIRECTION_VECS[dir]

static func vec_to_direction(vec: Vector3i) -> Direction:
	var idx := ALL_DIRECTION_VECS.find(vec)
	if idx < 0:
		push_error("Invalid direction passed to vec_to_direction: ", vec)
		return Direction.UP_RIGHT
	return idx as Direction

var tile_manager: M_TileManager

var _position: Vector3i
var position: Vector3i:
	get:
		return self._position

func _init(position_: Vector3i) -> void:
	self._position = position_

func on_incoming_light(_source: M_Tile, _light: M_Light) -> void:
	push_error("on_incoming_light() not implemented in " + str(self))
