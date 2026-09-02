extends Node3D
## Level 1 host: dollhouse, observation camera, and simulation.

var geometry: LevelGeometry
var camera: ObserverCamera
var sim: SimHost

func _ready() -> void:
	geometry = LevelGeometry.new()
	add_child(geometry)
	geometry.build()
	camera = ObserverCamera.new()
	camera.name = "Observer"
	add_child(camera)
	_ensure_overlay()
	_hint()
	call_deferred("_start_sim")


func _start_sim() -> void:
	sim = SimHost.new()
	sim.name = "Sim"
	add_child(sim)
	sim.setup(geometry)
	geometry.bake_for_play()
	var hud := GameHud.new()
	hud.name = "HUD"
	add_child(hud)
	hud.setup(sim)


func _hint() -> void:
	if has_node("Hint"):
		return
	var layer := CanvasLayer.new()
	layer.name = "Hint"
	layer.layer = 5
	add_child(layer)
	var lab := Label.new()
	lab.text = "RMB rotate  |  WASD pan  |  wheel zoom  |  R reset  |  F3 debug  |  Esc boot"
	lab.position = Vector2(520, 12)
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
