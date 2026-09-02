class_name Door
extends Node3D
## Simulated door. Closed doors block travel and line of sight.

signal opened

const HINGE_OFFSET_Z := 0.85
const OPEN_ANGLE := 155.0

@export var start_open: bool = false
@export var open_time: float = 0.85

var is_open: bool = false
var busy: bool = false
var _angle := 0.0
var _pivot: Node3D
var _body: StaticBody3D
var _mesh: MeshInstance3D
var _col: CollisionShape3D
var _gap: StaticBody3D
var _gap_col: CollisionShape3D
var _token: int = 0

func _ready() -> void:
	add_to_group(Conventions.GROUP_DOORS)
	_pivot = Node3D.new()
	_pivot.name = "Pivot"
	add_child(_pivot)
	_body = StaticBody3D.new()
	_body.name = "Panel"
	_body.collision_layer = Conventions.LAYER_WORLD | Conventions.LAYER_DOORS
	_body.collision_mask = 0
	_col = CollisionShape3D.new()
	_col.name = "CollisionShape3D"
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.16, 2.4, 2.12)
	_col.shape = shape
	_body.add_child(_col)
	_mesh = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.16, 2.4, 2.12)
	_mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.74, 0.46, 0.16)
	mat.roughness = 0.7
	_mesh.material_override = mat
	_body.add_child(_mesh)
	_body.position = Vector3(0.0, 0.0, HINGE_OFFSET_Z)
	_pivot.add_child(_body)
	_make_gap()
	if start_open:
		_set_open_instant(true)


func _make_gap() -> void:
	_gap = StaticBody3D.new()
	_gap.name = "Gap"
	_gap.position = Vector3(0.0, 0.0, HINGE_OFFSET_Z)
	_gap.collision_layer = Conventions.LAYER_WORLD | Conventions.LAYER_DOORS
	_gap.collision_mask = 0
	_gap_col = CollisionShape3D.new()
	var gshape := BoxShape3D.new()
	gshape.size = Vector3(0.22, 2.4, 2.08)
	_gap_col.shape = gshape
	_gap.add_child(_gap_col)
	add_child(_gap)


func xz_distance_to(from: Vector3) -> float:
	var opening := opening_position()
	return Vector2(from.x - opening.x, from.z - opening.z).length()


func opening_position() -> Vector3:
	return global_position + Vector3(0.0, 0.0, HINGE_OFFSET_Z)


func request_open(by: Node = null) -> void:
	if is_open or busy:
		return
	busy = true
	var token := _token
	_set_panel_solid(false)
	_emit_open_sound()
	if by != null and by.has_method("set_action"):
		by.call("set_action", "open_door")
	var t := 0.0
	while t < open_time:
		if token != _token:
			return
		if not _sim_running():
			await get_tree().physics_frame
			continue
		t += get_physics_process_delta_time()
		_angle = lerp(0.0, deg_to_rad(OPEN_ANGLE), clampf(t / open_time, 0.0, 1.0))
		_pivot.rotation.y = _angle
		await get_tree().physics_frame
	if token != _token:
		return
	_set_open_instant(true)
	opened.emit()


func abort_and_set(open: bool) -> void:
	_token += 1
	_set_open_instant(open)


func _set_panel_solid(solid: bool) -> void:
	_body.collision_layer = (Conventions.LAYER_WORLD | Conventions.LAYER_DOORS) if solid else 0
	if _col:
		_col.disabled = not solid


func _set_gap_solid(solid: bool) -> void:
	_gap.collision_layer = (Conventions.LAYER_WORLD | Conventions.LAYER_DOORS) if solid else 0
	if _gap_col:
		_gap_col.disabled = not solid


func _set_open_instant(open: bool) -> void:
	is_open = open
	busy = false
	_angle = deg_to_rad(OPEN_ANGLE) if open else 0.0
	_pivot.rotation.y = _angle
	_set_panel_solid(not open)
	_set_gap_solid(not open)
	if _mesh and _mesh.material_override:
		var mat := _mesh.material_override as StandardMaterial3D
		if mat:
			mat.albedo_color = Color(0.42, 0.28, 0.1) if open else Color(0.74, 0.46, 0.16)


func _sim_running() -> bool:
	var host := get_tree().get_first_node_in_group("sim")
	return host != null and bool(host.get("running"))


func _emit_open_sound() -> void:
	var host := get_tree().get_first_node_in_group("sim")
	if host is SimHost:
		(host as SimHost).emit_sound(opening_position(), 10.5, "door", name, false)
