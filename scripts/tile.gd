class_name M_Tile extends Node

const UP := Vector3i(0, -1, 1)
const UP_RIGHT := Vector3i(1, -1, 0)
const DOWN_RIGHT := Vector3i(1, 0, -1)
const DOWN := Vector3i(0, 1, -1)
const DOWN_LEFT := Vector3i(-1, 1, 0)
const UP_LEFT := Vector3i(-1, 0, 1)
const ALL_DIRECTIONS: Array[Vector3i] = [UP, UP_RIGHT, DOWN_RIGHT, DOWN, DOWN_LEFT, UP_LEFT]

var tile_manager: M_TileManager

var _position: Vector3i
var position: Vector3i:
	get:
		return self._position

func _init(position_: Vector3i) -> void:
	self._position = position_

func on_incoming_light(_source: M_Tile, _light: M_Light) -> void:
	push_error("on_incoming_light() not implemented in " + str(self))
