class_name M_Light

enum M_Color {
	BLACK = 0,
	RED = 1 << 0,
	GREEN = 1 << 1,
	BLUE = 1 << 2,

	YELLOW = RED | GREEN,
	PURPLE = RED | BLUE,
	CYAN = BLUE | GREEN,

	WHITE = RED | GREEN | BLUE,
}

var strength: int
var color: M_Color = M_Color.WHITE

func _init(color_: M_Color, strength_: int) -> void:
	self.color = color_
	self.strength = strength_

static func _color_name(color_: M_Color) -> String:
	match color_:
		M_Color.BLACK: return "BLACK"
		M_Color.RED: return "RED"
		M_Color.GREEN: return "GREEN"
		M_Color.BLUE: return "BLUE"
		M_Color.YELLOW: return "YELLOW"
		M_Color.PURPLE: return "PURPLE"
		M_Color.CYAN: return "CYAN"
		M_Color.WHITE: return "WHITE"
		_: return "UNKNOWN"

func _to_string() -> String:
	return "%s(%d)" % [_color_name(self.color), self.strength]

static func black() -> M_Light:
	return M_Light.new(M_Color.BLACK, 0)

func is_black() -> bool:
	return self.color == M_Color.BLACK || self.strength == 0

func weaken() -> M_Light:
	var new_strength: int = max(self.strength - 1, 0)
	return M_Light.new(self.color, new_strength)
