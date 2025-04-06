class_name ItemButton extends Control

@export var _button: Button
@export var _counter_label: Label

signal button_pressed
signal counter_updated

var _type: Global.ItemType

func setup(type: Global.ItemType) -> void:
	self._type = type
	self._button.text = Global.ItemTypeToName[self._type]

func _on_button_pressed() -> void:
	self.button_pressed.emit(self._type)

func update_counter(counter: int) -> void:
	self._counter_label.text = str(counter)
