class_name LevelGeometry
extends Node3D
## Readable dollhouse for Level 1. Rooms, doors, cover, two routes.

const WALL_H := 3.0
const WALL_T := 0.3

var markers: Dictionary = {}
var _nav_walk: Array = []
var _nav_block: Array = []
var nav_poly_count: int = 0

func build() -> void:
	name = "World"
	_nav_walk.clear()
	_nav_block.clear()
	_environment()
	_floors()
	_walls()
	_cover()
	_door_panels()
	_labels()
	_setup_nav()


func _setup_nav() -> void:
	var region := NavigationRegion3D.new()
	region.name = "Nav"
	var nmesh := NavigationMesh.new()
	nmesh.agent_radius = 0.42
	nmesh.agent_height = 1.6
	nmesh.agent_max_climb = 0.15
	nmesh.agent_max_slope = 45.0
	nmesh.cell_size = 0.15
	nmesh.cell_height = 0.15
	nmesh.border_size = 0.0
	var src := NavigationMeshSourceGeometryData3D.new()
	for item in _nav_walk:
		var c: Vector3 = item["c"]
		var s: Vector3 = item["s"]
		var y: float = c.y + s.y * 0.5
		var hx := s.x * 0.5
		var hz := s.z * 0.5
		var p0 := Vector3(c.x - hx, y, c.z - hz)
		var p1 := Vector3(c.x + hx, y, c.z - hz)
		var p2 := Vector3(c.x + hx, y, c.z + hz)
		var p3 := Vector3(c.x - hx, y, c.z + hz)
		src.add_faces(PackedVector3Array([p0, p1, p2, p0, p2, p3]), Transform3D.IDENTITY)
	for item in _nav_block:
		var c: Vector3 = item["c"]
		var s: Vector3 = item["s"]
		var hx := s.x * 0.5 + 0.08
		var hz := s.z * 0.5 + 0.08
		var verts := PackedVector3Array([
			Vector3(c.x - hx, 0.0, c.z - hz),
			Vector3(c.x + hx, 0.0, c.z - hz),
			Vector3(c.x + hx, 0.0, c.z + hz),
			Vector3(c.x - hx, 0.0, c.z + hz)
		])
		src.add_projected_obstruction(verts, 0.0, 3.0, true)
	NavigationServer3D.bake_from_source_geometry_data(nmesh, src, Callable())
	nav_poly_count = nmesh.get_polygon_count()
	region.navigation_mesh = nmesh
	add_child(region)


func _environment() -> void:
	var world := WorldEnvironment.new()
	world.name = "WorldEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.07, 0.08, 0.1, 1)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.5, 0.52, 0.55)
	env.ambient_light_energy = 0.7
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, 40, 0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)


func _floors() -> void:
	_box(Vector3(0, -0.1, 2.5), Vector3(5.4, 0.2, 5.2), Color(0.18, 0.2, 0.22), "floor_entrance")
	_box(Vector3(0, -0.1, 9.5), Vector3(3.8, 0.2, 9.2), Color(0.2, 0.22, 0.24), "floor_corridor")
	_box(Vector3(3.0, -0.1, 18.0), Vector3(14.4, 0.2, 8.2), Color(0.22, 0.24, 0.27), "floor_central")
	_box(Vector3(-8.1, -0.1, 18.0), Vector3(8.0, 0.2, 8.2), Color(0.25, 0.2, 0.17), "floor_room_a")
	_box(Vector3(13.2, -0.1, 18.0), Vector3(6.4, 0.2, 8.2), Color(0.19, 0.21, 0.24), "floor_room_b")
	_box(Vector3(1.0, -0.1, 23.4), Vector3(28.4, 0.2, 3.0), Color(0.21, 0.23, 0.25), "floor_north")
	_box(Vector3(13.6, -0.1, 25.8), Vector3(4.6, 0.2, 3.4), Color(0.16, 0.24, 0.19), "floor_exit")


func _walls() -> void:
	var w := Color(0.43, 0.45, 0.47)
	# Entrance
	_box(Vector3(0, 1.5, 0.0), Vector3(5.4, WALL_H, WALL_T), w, "w_ent_s")
	_box(Vector3(-2.7, 1.5, 2.5), Vector3(WALL_T, WALL_H, 5.2), w, "w_ent_w")
	_box(Vector3(2.7, 1.5, 2.5), Vector3(WALL_T, WALL_H, 5.2), w, "w_ent_e")
	# Corridor
	_box(Vector3(-1.9, 1.5, 9.5), Vector3(WALL_T, WALL_H, 9.0), w, "w_cor_w")
	_box(Vector3(1.9, 1.5, 9.5), Vector3(WALL_T, WALL_H, 9.0), w, "w_cor_e")
	# Central south, corridor gap x=-1.8..1.8
	_box(Vector3(-3.15, 1.5, 14.0), Vector3(2.1, WALL_H, WALL_T), w, "w_cen_s_w")
	_box(Vector3(6.05, 1.5, 14.0), Vector3(8.3, WALL_H, WALL_T), w, "w_cen_s_e")
	# Central north, gap x=-1.2..2.4 toward north hall
	_box(Vector3(-2.7, 1.5, 22.0), Vector3(1.8, WALL_H, WALL_T), w, "w_cen_n_w")
	_box(Vector3(6.3, 1.5, 22.0), Vector3(7.6, WALL_H, WALL_T), w, "w_cen_n_e")
	# Room A outer
	_box(Vector3(-12.15, 1.5, 18.0), Vector3(WALL_T, WALL_H, 8.2), w, "w_a_w")
	_box(Vector3(-8.1, 1.5, 14.0), Vector3(8.0, WALL_H, WALL_T), w, "w_a_s")
	# Room A north with bypass gap x=-9.4..-6.8
	_box(Vector3(-11.15, 1.5, 22.0), Vector3(2.0, WALL_H, WALL_T), w, "w_a_n_w")
	_box(Vector3(-5.4, 1.5, 22.0), Vector3(2.6, WALL_H, WALL_T), w, "w_a_n_e")
	# Room A east with door gap z=17.2..18.9
	_box(Vector3(-4.1, 1.5, 15.45), Vector3(WALL_T, WALL_H, 2.9), w, "w_a_e_s")
	_box(Vector3(-4.1, 1.5, 20.55), Vector3(WALL_T, WALL_H, 2.9), w, "w_a_e_n")
	# Room B outer
	_box(Vector3(16.4, 1.5, 18.0), Vector3(WALL_T, WALL_H, 8.2), w, "w_b_e")
	_box(Vector3(13.2, 1.5, 14.0), Vector3(6.4, WALL_H, WALL_T), w, "w_b_s")
	# Room B west with door gap
	_box(Vector3(10.1, 1.5, 15.45), Vector3(WALL_T, WALL_H, 2.9), w, "w_b_w_s")
	_box(Vector3(10.1, 1.5, 20.55), Vector3(WALL_T, WALL_H, 2.9), w, "w_b_w_n")
	# Room B north with exit gap x=12.4..15.0
	_box(Vector3(11.0, 1.5, 22.0), Vector3(1.8, WALL_H, WALL_T), w, "w_b_n_w")
	_box(Vector3(15.7, 1.5, 22.0), Vector3(1.4, WALL_H, WALL_T), w, "w_b_n_e")
	# North hall
	_box(Vector3(1.0, 1.5, 24.9), Vector3(28.6, WALL_H, WALL_T), w, "w_nh_n")
	_box(Vector3(-12.2, 1.5, 23.4), Vector3(WALL_T, WALL_H, 3.0), w, "w_nh_w")
	_box(Vector3(16.4, 1.5, 23.4), Vector3(WALL_T, WALL_H, 3.0), w, "w_nh_e")
	# Secondary exit
	_box(Vector3(11.3, 1.5, 25.8), Vector3(WALL_T, WALL_H, 3.4), w, "w_ex_w")
	_box(Vector3(15.9, 1.5, 25.8), Vector3(WALL_T, WALL_H, 3.4), w, "w_ex_e")
	_box(Vector3(13.6, 1.5, 27.5), Vector3(4.6, WALL_H, WALL_T), w, "w_ex_n")


func _cover() -> void:
	var c := Color(0.3, 0.33, 0.37)
	_box(Vector3(2.5, 1.15, 17.1), Vector3(2.8, 2.3, 0.4), c, "cover_front")
	_box(Vector3(3.7, 1.15, 18.5), Vector3(0.4, 2.3, 2.8), c, "cover_side")
	markers["blind"] = Vector3(2.2, 0.0, 18.8)


func _door_panels() -> void:
	markers["door_a"] = Vector3(-4.1, 1.2, 18.05)
	_box(Vector3(-4.1, 1.2, 18.05), Vector3(0.14, 2.4, 1.65), Color(0.74, 0.46, 0.16), "door_a_panel")
	markers["door_b"] = Vector3(10.1, 1.2, 18.05)
	_box(Vector3(10.1, 1.2, 18.05), Vector3(0.14, 2.4, 1.65), Color(0.74, 0.46, 0.16), "door_b_panel")


func _labels() -> void:
	_mark("ENTRANCE", Vector3(0, 2.45, 2.3), Color(0.85, 0.9, 0.95))
	_mark("CORRIDOR", Vector3(0, 2.45, 9.5), Color(0.85, 0.9, 0.95))
	_mark("CENTRAL", Vector3(3.2, 2.45, 18.0), Color(0.85, 0.9, 0.95))
	_mark("ROOM A", Vector3(-8.0, 2.45, 18.0), Color(0.95, 0.72, 0.45))
	_mark("ROOM B", Vector3(13.2, 2.45, 18.0), Color(0.85, 0.9, 0.95))
	_mark("EXIT", Vector3(13.6, 2.45, 25.6), Color(0.5, 0.92, 0.62))
	markers["entrance"] = Vector3(0, 0, 2.4)
	markers["room_a"] = Vector3(-8.0, 0, 18.0)
	markers["room_b"] = Vector3(13.2, 0, 18.0)
	markers["central"] = Vector3(3.0, 0, 18.0)
	markers["exit"] = Vector3(13.6, 0, 25.8)
	markers["corridor"] = Vector3(0, 0, 9.5)
	markers["central_north"] = Vector3(0.0, 0, 20.6)
	markers["north_hall"] = Vector3(0.15, 0, 23.4)
	markers["room_a_north"] = Vector3(-8.1, 0, 23.4)
	markers["room_a_flank"] = Vector3(-8.6, 0, 20.1)
	markers["room_b_north"] = Vector3(13.6, 0, 23.4)


func spawn_mannequin(at: Vector3, color: Color, label: String) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.32
	cap.height = 1.7
	mesh.mesh = cap
	mesh.position = at + Vector3(0, 0.9, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material_override = mat
	add_child(mesh)
	_mark(label, at + Vector3(0, 2.15, 0), color)
	return mesh


func _box(center: Vector3, size: Vector3, color: Color, node_name: String) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = center
	body.collision_layer = Conventions.LAYER_WORLD
	body.collision_mask = 0
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.82
	mi.material_override = mat
	body.add_child(mi)
	add_child(body)
	if node_name.begins_with("floor_"):
		_nav_walk.append({"c": center, "s": size})
	elif not node_name.begins_with("door_"):
		_nav_block.append({"c": center, "s": size})
	return body


func _mark(text: String, pos: Vector3, color: Color) -> void:
	var lab := Label3D.new()
	lab.text = text
	lab.position = pos
	lab.font_size = 42
	lab.modulate = color
	lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lab.outline_size = 6
	add_child(lab)
