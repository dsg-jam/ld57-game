class_name M_Light

enum M_Color {
	RED = 1 << 1,
	GREEN = 1 << 2,
	BLUE = 1 << 3,
	WHITE = RED | GREEN | BLUE,
}

var strength: int
var color: M_Color = M_Color.WHITE

func _init(color_: M_Color, strength_: int) -> void:
	self.color = color_
	self.strength = strength_

func weaken() -> M_Light:
	var new_strength: int = max(self.strength - 1, 0)
	return M_Light.new(self.color, new_strength)
