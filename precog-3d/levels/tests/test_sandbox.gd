extends Node3D
## Isolated test scene. Independent from Level 1.

func _ready() -> void:
	_build()


func _build() -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50, 30, 0)
	light.shadow_enabled = true
	add_child(light)

	var cam := Camera3D.new()
	cam.position = Vector3(0, 6, 10)
	cam.look_at_from_position(cam.position, Vector3.ZERO, Vector3.UP)
	cam.current = true
	add_child(cam)

	_box(Vector3(8, 0.1, 8), Vector3(0, -0.1, 0), Color(0.22, 0.24, 0.26))
	_box(Vector3(1, 1.8, 1), Vector3(0, 0.9, 0), Color(0.2, 0.55, 0.95))

	var overlay := preload("res://debug/debug_overlay.tscn").instantiate()
	add_child(overlay)

	var hud := Label.new()
	hud.text = "TEST SANDBOX  |  Esc boot  |  F3 debug"
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)
	hud.position = Vector2(16, 12)
	root.add_child(hud)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		App.go_boot()


func _box(size: Vector3, pos: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material_override = mat
	add_child(mesh)
	var body := StaticBody3D.new()
	body.position = pos
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	add_child(body)
