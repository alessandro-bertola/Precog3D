extends CanvasLayer
## On-screen debug banner. Visible only when DebugMode is on.

var _banner: Label
var _detail: Label
var _root: Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_banner = Label.new()
	_banner.position = Vector2(16, 40)
	_banner.add_theme_font_size_override("font_size", 22)
	_banner.modulate = Color(1.0, 0.75, 0.2, 1)
	_root.add_child(_banner)

	_detail = Label.new()
	_detail.position = Vector2(16, 72)
	_detail.add_theme_font_size_override("font_size", 14)
	_root.add_child(_detail)

	DebugMode.changed.connect(_on_debug_changed)
	_apply(DebugMode.enabled)


func _process(_delta: float) -> void:
	if not DebugMode.enabled:
		return
	var pawn := DebugMode.selected_pawn
	if pawn != null and is_instance_valid(pawn) and pawn.has_method("debug_text"):
		_detail.text = str(pawn.call("debug_text"))
	else:
		_detail.text = "F3 debug  |  click a character to inspect"


func _on_debug_changed(enabled: bool) -> void:
	_apply(enabled)


func _apply(enabled: bool) -> void:
	_root.visible = enabled
	_banner.text = "DEBUG ON" if enabled else ""
