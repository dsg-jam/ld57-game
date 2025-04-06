class_name ItemButton extends Panel

@export var button: Button

signal button_pressed

var _type: Global.ItemType

func setup(type: Global.ItemType) -> void:
	self._type = type
	button.text = Global.ItemTypeToName[self._type]

func _on_button_pressed() -> void:
	self.button_pressed.emit(self._type)
