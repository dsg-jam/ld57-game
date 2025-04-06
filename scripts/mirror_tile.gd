class_name M_MirrorTile extends M_Tile

var _normal_dir: Direction

func _init(position_: Vector3i, normal_dir_: Direction) -> void:
	super (position_)
	self._normal_dir = normal_dir_

func on_incoming_light(source: M_Tile, light: M_Light) -> void:
	var dir_vec := self._position - source.position
	var dir := vec_to_direction(dir_vec)
	# We add 3 to invert the incoming direction.
	var signed_dir_diff := posmod(3 + self._normal_dir - dir, 6)
	if signed_dir_diff > 3:
		signed_dir_diff -= 6
	if abs(signed_dir_diff) > 1:
		# Light is hitting our back or sides, not the actual mirror
		return

	var new_dir := posmod(self._normal_dir + signed_dir_diff, 6)
	var new_dir_vec := direction_to_vec(new_dir)
	var tile := self.tile_manager.get_tile(self._position + new_dir_vec)
	if not tile:
		return
	tile.on_incoming_light(self, light.weaken())
