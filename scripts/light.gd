class_name M_Light

enum M_Color {
	BLACK   = 0,            # 0
	RED     = 1 << 0,       # 1
	GREEN   = 1 << 1,       # 2
	YELLOW  = RED | GREEN,  # 3
	BLUE    = 1 << 2,       # 4
	MAGENTA = RED | BLUE,   # 5
	CYAN    = BLUE | GREEN, # 6
	WHITE   = RED | GREEN | BLUE, # 7
}

static func _color_name(color_: M_Color) -> String:
	return M_Color.keys()[color_]

var _id: int
var id: int:
	get: return self._id

var strength: int
var color: M_Color = M_Color.WHITE

func _init(id_: int, color_: M_Color, strength_: int = 80) -> void:
	self.color = color_
	self.strength = strength_
	self._id = id_

func _to_string() -> String:
	return "%s(%d)@%d" % [_color_name(self.color), self.strength, self._id]

static func black() -> M_Light:
	return M_Light.new(-1, M_Color.BLACK, 0)

static func combine(a: M_Light, b: M_Light) -> M_Light:
	if a.is_black(): return b
	if b.is_black(): return a
	return M_Light.new(a.id + b.id, a.color | b.color, min(a.strength, b.strength))

func is_black() -> bool:
	return self.color == M_Color.BLACK || self.strength <= 0

func weaken() -> M_Light:
	var new_strength: int = max(self.strength - 1, 0)
	return M_Light.new(self._id, self.color, new_strength)

func split_red() -> M_Light:
	return M_Light.new(self._id, self.color & M_Color.RED, self.strength)

func split_green() -> M_Light:
	return M_Light.new(self._id, self.color & M_Color.GREEN, self.strength)

func split_blue() -> M_Light:
	return M_Light.new(self._id, self.color & M_Color.BLUE, self.strength)
