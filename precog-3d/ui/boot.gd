extends Control
## Game entry. No gameplay. Routes to the test sandbox or Level 1.

func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.07, 0.09, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-280, -160)
	box.custom_minimum_size = Vector2(560, 320)
	box.add_theme_constant_override("separation", 14)
	add_child(box)

	var title := Label.new()
	title.text = "PRECOG"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	box.add_child(title)

	var sub := Label.new()
	title_modulate_info(sub)
	sub.text = "THE PLAYER DOES NOT MOVE PEOPLE.\nTHE PLAYER MOVES INFORMATION.\n\nWatch a future. Return. Warn. Watch again. Commit."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)

	var b1 := Button.new()
	b1.text = "Open Level 1"
	b1.pressed.connect(App.go_level)
	box.add_child(b1)

	var b2 := Button.new()
	b2.text = "Open Test Sandbox"
	b2.pressed.connect(App.go_test)
	box.add_child(b2)

	var hint := Label.new()
	hint.text = "F3 toggles debug overlay. Development build."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(hint)


func title_modulate_info(sub: Label) -> void:
	sub.add_theme_font_size_override("font_size", 16)
	sub.modulate = Color(0.75, 0.82, 0.9, 1)
