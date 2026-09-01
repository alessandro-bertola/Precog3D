extends Node3D
## Level 1 host scene. Geometry and simulation are added in later phases.

func _ready() -> void:
	if not has_node("Camera3D"):
		var cam := Camera3D.new()
		cam.name = "Camera3D"
		cam.position = Vector3(0, 8, 12)
		add_child(cam)
		cam.look_at(Vector3.ZERO, Vector3.UP)
	if not has_node("Sun"):
		var light := DirectionalLight3D.new()
		light.name = "Sun"
		light.rotation_degrees = Vector3(-50, 35, 0)
		add_child(light)
	_ensure_overlay()


func _ensure_overlay() -> void:
	if has_node("DebugOverlay"):
		return
	var overlay := preload("res://debug/debug_overlay.tscn").instantiate()
	overlay.name = "DebugOverlay"
	add_child(overlay)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		App.go_boot()
