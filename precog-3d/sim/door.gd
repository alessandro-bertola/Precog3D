class_name Door
extends Node3D
## Simulated door. Closed doors block travel and line of sight.

signal opened
signal closed

@export var start_open: bool = false
@export var open_time: float = 0.85

var is_open: bool = false
var busy: bool = false
var _angle := 0.0
var _body: StaticBody3D
var _mesh: MeshInstance3D

func _ready() -> void:
	add_to_group(Conventions.GROUP_DOORS)
	_body = StaticBody3D.new()
	_body.collision_layer = Conventions.LAYER_WORLD | Conventions.LAYER_DOORS
	_body.collision_mask = 0
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.16, 2.4, 1.7)
	col.shape = shape
	_body.add_child(col)
	_mesh = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.16, 2.4, 1.7)
	_mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.74, 0.46, 0.16)
	mat.roughness = 0.7
	_mesh.material_override = mat
	_body.add_child(_mesh)
	add_child(_body)
	if start_open:
		_set_open_instant(true)


func request_open(by: Node = null) -> void:
	if is_open or busy:
		return
	busy = true
	if by != null and by.has_method("set_action"):
		by.call("set_action", "open_door")
	var t := 0.0
	while t < open_time:
		if not _sim_running():
			await get_tree().process_frame
			continue
		t += get_process_delta_time()
		_angle = lerp(0.0, deg_to_rad(92.0), clampf(t / open_time, 0.0, 1.0))
		rotation.y = _angle
		await get_tree().process_frame
	_set_open_instant(true)
	busy = false
	opened.emit()


func _set_open_instant(open: bool) -> void:
	is_open = open
	_angle = deg_to_rad(92.0) if open else 0.0
	rotation.y = _angle
	_body.collision_layer = 0 if open else (Conventions.LAYER_WORLD | Conventions.LAYER_DOORS)
	if _body.has_node("CollisionShape3D"):
		(_body.get_node("CollisionShape3D") as CollisionShape3D).disabled = open


func _sim_running() -> bool:
	var host := get_tree().get_first_node_in_group("sim")
	return host == null or bool(host.get("running"))
