class_name GameHud
extends CanvasLayer
## Present / projection / execution UI. Observation only, no direct orders.

var host: SimHost
var _mode: Label
var _budget: Label
var _time: Label
var _log: RichTextLabel
var _why: Label
var _compare: Label
var _target: OptionButton
var _outcome: Label
var _btn_play: Button
var _btn_pause: Button
var _btn_project: Button

func setup(h: SimHost) -> void:
	host = h
	layer = 20
	_build()
	host.mode_changed.connect(_on_mode)
	host.timeline_event.connect(_on_event)
	host.budget_changed.connect(_on_budget)
	_on_mode(host.mode_name())
	_on_budget(host.budget)


func _build() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_mode = _lab(root, Vector2(16, 40), 28)
	_time = _lab(root, Vector2(16, 74), 16)
	_budget = _lab(root, Vector2(16, 96), 16)
	_outcome = _lab(root, Vector2(16, 118), 16)
	_outcome.modulate = Color(1, 0.8, 0.4)
	var panel := VBoxContainer.new()
	panel.position = Vector2(16, 150)
	panel.custom_minimum_size = Vector2(280, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(panel)
	_btn_play = _btn(panel, "Play present", _play)
	_btn_pause = _btn(panel, "Pause present", _pause)
	_btn_project = _btn(panel, "Project future", _project)
	_btn(panel, "Return to present", _return)
	_btn(panel, "Execute", _execute)
	_target = OptionButton.new()
	_target.add_item(Conventions.AGENT_A)
	_target.add_item(Conventions.AGENT_B)
	panel.add_child(_target)
	_btn(panel, "Warn: hostile in Room A (1)", func(): _precog("hostile_room_a"))
	_btn(panel, "Warn: hostile in Room B (1)", func(): _precog("hostile_room_b"))
	_btn(panel, "Precise position Room A (2)", func(): _precog("position"))
	_btn(panel, "Precise position Room B (2)", func(): _precog("position_b"))
	_btn(panel, "Directive cautious (1)", func(): _precog("cautious"))
	_btn(panel, "Directive decisive (1)", func(): _precog("decisive"))
	_btn(panel, "Directive stealth (1)", func(): _precog("stealth"))
	_btn(panel, "Priority civilian (1)", func(): _precog("priority_civ"))
	_log = RichTextLabel.new()
	_log.position = Vector2(16, 520)
	_log.size = Vector2(420, 220)
	_log.bbcode_enabled = true
	_log.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_log)
	_why = _lab(root, Vector2(1100, 40), 14)
	_why.size = Vector2(480, 220)
	_compare = _lab(root, Vector2(1100, 280), 14)
	_compare.size = Vector2(480, 240)
	var hint := _lab(root, Vector2(16, 860), 14)
	hint.text = "Play present to let real time flow, Pause to lock a new present, then Project that future.\nReturn discards a projection. Execute commits. You do not move people. You move information."


func _process(_delta: float) -> void:
	if host == null or _btn_project == null:
		return
	_time.text = "T+%.1fs / %.0fs" % [host.sim_time, host.horizon]
	_outcome.text = host.last_outcome
	if host.mode == SimHost.Mode.PROJECTION and not host.running:
		_btn_project.text = "Continue future"
	else:
		_btn_project.text = "Project future"
	var in_present := host.mode == SimHost.Mode.PRESENT
	_btn_play.disabled = (not in_present) or host.running or host.committed
	_btn_pause.disabled = (not in_present) or (not host.running)
	if host.mode == SimHost.Mode.EXECUTION and not host.running and host.last_outcome != "":
		_why.text = "DEBRIEF\n" + host.last_outcome + "\nThe future was a rehearsal. This was the operation."
	_refresh_why()
	_refresh_compare()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if host:
			host.select_pawn_at_mouse()


func _play() -> void:
	host.play_present()


func _pause() -> void:
	host.pause_present()


func _project() -> void:
	host.start_projection()


func _return() -> void:
	host.stop_projection(true)


func _execute() -> void:
	host.start_execution()


func _precog(kind: String) -> void:
	var target_name := _target.get_item_text(_target.selected)
	var ok := host.apply_precog(kind, target_name)
	if not ok:
		_outcome.text = "Not enough Precog or not in PRESENT"


func _on_mode(m: String) -> void:
	if host.mode == SimHost.Mode.PRESENT and host.running:
		_mode.text = "PRESENT LIVE"
		_mode.modulate = Color(0.55, 1.0, 0.6)
		return
	_mode.text = m
	match m:
		"PRESENT":
			_mode.modulate = Color(0.85, 0.9, 1.0)
		"PROJECTION":
			_mode.modulate = Color(0.45, 0.85, 1.0)
		_:
			_mode.modulate = Color(1.0, 0.55, 0.4)


func _on_budget(v: int) -> void:
	_budget.text = "Precog points: %d/%d" % [v, host.budget_max]


func _on_event(entry: Dictionary) -> void:
	_log.append_text("[+%0.1f] %s\n" % [entry.t, entry.text])


func _refresh_why() -> void:
	var pawn := DebugMode.selected_pawn
	if pawn is Pawn:
		_why.text = "WHY\n" + (pawn as Pawn).debug_text()
	else:
		_why.text = "WHY\nSelect a character (debug click) to see knowledge and intent."


func _refresh_compare() -> void:
	if host.prev_timeline().is_empty():
		_compare.text = "COMPARE\nRun a second projection to see what changed."
		return
	var a := host.prev_timeline().size()
	var b := host.timeline().size()
	_compare.text = "COMPARE\nPrevious events: %d\nCurrent events: %d\nLast outcome: %s" % [a, b, host.last_outcome]


func _lab(parent: Node, pos: Vector2, size: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	parent.add_child(l)
	return l


func _btn(parent: Node, text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.pressed.connect(cb)
	parent.add_child(b)
	return b
