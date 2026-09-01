extends Node3D
## Level 1 host. Phase 2: readable diorama and observation camera.

var geometry: LevelGeometry
var camera: ObserverCamera

func _ready() -> void:
	if has_node("World"):
		geometry = $World as LevelGeometry
	else:
		geometry = LevelGeometry.new()
		add_child(geometry)
		geometry.build()
		geometry.spawn_mannequin(Vector3(0, 0, 2.4), Color(0.25, 0.55, 0.95), "SCALE")
		geometry.spawn_mannequin(Vector3(2.2, 0, 18.8), Color(0.75, 0.25, 0.22), "HIDDEN")
		call_deferred("_bake")
	if not has_node("Observer"):
		camera = ObserverCamera.new()
		camera.name = "Observer"
		add_child(camera)
	_ensure_overlay()
	_hint()


func _bake() -> void:
	if geometry:
		geometry.bake_now()


func _hint() -> void:
	if has_node("Hint"):
		return
	var layer := CanvasLayer.new()
	layer.name = "Hint"
	add_child(layer)
	var lab := Label.new()
	lab.text = "RMB rotate  |  WASD pan  |  wheel zoom  |  R reset  |  F3 debug  |  Esc boot"
	lab.position = Vector2(16, 12)
	layer.add_child(lab)


func _ensure_overlay() -> void:
	if has_node("DebugOverlay"):
		return
	var overlay := preload("res://debug/debug_overlay.tscn").instantiate()
	overlay.name = "DebugOverlay"
	add_child(overlay)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		App.go_boot()
