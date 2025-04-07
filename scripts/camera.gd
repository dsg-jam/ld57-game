class_name M_Camera extends Camera2D

const SCROLL_SPEED: float = 12.0

var _min_pos: float
var _max_pos: float = 200.0

func _ready() -> void:
	self._min_pos = self.position.y

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mouse_event := event as InputEventMouseButton
	var scroll_diff := SCROLL_SPEED * mouse_event.factor
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		self.position.y = max(self.position.y - scroll_diff, self._min_pos)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		self.position.y = min(scroll_diff + self.position.y, self._max_pos)

func set_max(y: float):
	self._max_pos = max(y - 2 * self.get_viewport_rect().size.y / 5, self._max_pos)
