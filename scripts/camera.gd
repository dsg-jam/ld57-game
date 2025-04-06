extends Camera2D

const SCROLL_SPEED: int = 3

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			self.position.y -= SCROLL_SPEED
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			self.position.y += SCROLL_SPEED
