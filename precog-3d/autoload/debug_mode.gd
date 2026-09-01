extends Node
## Development debug overlay. Does not change simulation rules.

signal changed(enabled: bool)

var enabled: bool = false
var selected_pawn: Node = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		set_enabled(not enabled)
		get_viewport().set_input_as_handled()


func set_enabled(value: bool) -> void:
	if enabled == value:
		return
	enabled = value
	changed.emit(enabled)
