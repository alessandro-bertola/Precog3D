class_name Pawn
extends CharacterBody3D
## Autonomous character. Acts only on own knowledge. No player motor control.

enum Faction { AGENT, CRIMINAL, CIVILIAN }
enum Stance { CAUTIOUS, DECISIVE, STEALTH }

signal downed_changed(pawn)

@export var display_name: String = "Pawn"
@export var faction: Faction = Faction.AGENT
@export var caution: float = 0.55
@export var move_speed: float = 3.15
@export var max_hp: float = 100.0
@export var vision_range: float = 12.0
@export var vision_fov: float = 70.0
@export var fire_range: float = 9.0

var hp: float = 100.0
var downed: bool = false
var stance: Stance = Stance.DECISIVE
var goal_text: String = "idle"
var current_action: String = "idle"
var goal_pos: Vector3 = Vector3.INF
var knowledge: KnowledgeStore = KnowledgeStore.new()
var last_radio_time: float = -999.0
var priority_civilian: bool = false
var blocked_reason: String = ""
var fire_cd: float = 0.0
var spawn_xform: Transform3D
var spawn_goal: Vector3 = Vector3.INF
var spawn_goal_text: String = "idle"

var _nav: NavigationAgent3D
var _label: Label3D
var _mesh: MeshInstance3D
var _eye: Marker3D

func _ready() -> void:
	hp = max_hp
	spawn_xform = global_transform
	add_to_group(Conventions.GROUP_PAWNS)
	if faction == Faction.AGENT:
		add_to_group(Conventions.GROUP_AGENTS)
	elif faction == Faction.CRIMINAL:
		add_to_group(Conventions.GROUP_CRIMINALS)
	else:
		add_to_group(Conventions.GROUP_CIVILIANS)
	collision_layer = Conventions.LAYER_CHARACTERS
	collision_mask = Conventions.LAYER_WORLD | Conventions.LAYER_DOORS
	_build_visual()
	_nav = NavigationAgent3D.new()
	_nav.path_desired_distance = 0.4
	_nav.target_desired_distance = 0.55
	_nav.radius = 0.38
	_nav.avoidance_enabled = true
	_nav.avoidance_layers = 1
	add_child(_nav)
	floor_snap_length = 0.3


func _build_visual() -> void:
	var cap := CapsuleMesh.new()
	cap.radius = 0.32
	cap.height = 1.65
	_mesh = MeshInstance3D.new()
	_mesh.mesh = cap
	_mesh.position = Vector3(0, 0.9, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = _color()
	_mesh.material_override = mat
	add_child(_mesh)
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.32
	shape.height = 1.65
	col.shape = shape
	col.position = Vector3(0, 0.9, 0)
	add_child(col)
	_label = Label3D.new()
	_label.text = display_name
	_label.position = Vector3(0, 2.05, 0)
	_label.font_size = 36
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(_label)
	_eye = Marker3D.new()
	_eye.position = Vector3(0, 1.55, 0)
	add_child(_eye)
	var face := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.18, 0.08, 0.18)
	face.mesh = box
	face.position = Vector3(0, 1.55, -0.28)
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color(0.95, 0.95, 0.9)
	face.material_override = fm
	add_child(face)


func _color() -> Color:
	match faction:
		Faction.AGENT:
			return Color(0.22, 0.52, 0.95) if caution >= 0.55 else Color(0.15, 0.7, 0.85)
		Faction.CRIMINAL:
			return Color(0.82, 0.22, 0.18)
		_:
			return Color(0.9, 0.78, 0.2)


func set_goal(pos: Vector3, text: String) -> void:
	goal_pos = pos
	goal_text = text
	if spawn_goal.x == INF:
		spawn_goal = pos
		spawn_goal_text = text
	if not downed and pos.x != INF:
		_nav.target_position = pos


func set_action(text: String) -> void:
	current_action = text


func _physics_process(delta: float) -> void:
	if not _sim_running() or downed:
		velocity = Vector3.ZERO
		return
	fire_cd = maxf(0.0, fire_cd - delta)
	_sense()
	_decide()
	_move(delta)
	_try_shoot()
	_try_radio()
	_update_label()


func _sim_running() -> bool:
	var host := get_tree().get_first_node_in_group("sim")
	return host == null or bool(host.get("running"))


func _sense() -> void:
	var now := _time()
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_PAWNS):
		if p == self or not (p is Pawn):
			continue
		var other := p as Pawn
		if other.downed:
			continue
		if _can_see(other):
			knowledge.see(other.display_name, other.global_position, now, _room_of(other.global_position))
		else:
			knowledge.mark_lost(other.display_name)
	for ev in _bus_sounds():
		var dist := global_position.distance_to(ev.pos)
		if dist <= ev.radius:
			var noisy := ev.pos + Vector3(randf_range(-1.2, 1.2), 0, randf_range(-1.2, 1.2)) * (dist / maxf(ev.radius, 0.1))
			knowledge.hear(ev.src, noisy, now)
			if faction == Faction.CIVILIAN and ev.kind == "gunshot":
				priority_civilian = true
				set_goal(_marker("exit"), "flee_exit")


func _decide() -> void:
	if downed:
		current_action = "downed"
		return
	if faction == Faction.CIVILIAN:
		if knowledge.debug_lines().contains("gunshot") or goal_text == "flee_exit":
			current_action = "flee"
			return
		current_action = "wait"
		return
	if faction == Faction.CRIMINAL:
		_decide_criminal()
		return
	_decide_agent()


func _decide_agent() -> void:
	if priority_civilian:
		var civ := _find_named(Conventions.CIVILIAN)
		if civ and knowledge.get_fact(civ.display_name) and knowledge.get_fact(civ.display_name).seen_now:
			goal_text = "protect_civilian"
	var hostile_room_a := knowledge.knows_hostile_in("room_a")
	if goal_text.begins_with("secure") or goal_text == "reach_room_a":
		if hostile_room_a and stance == Stance.CAUTIOUS:
			set_goal(_marker("central") + Vector3(-1.5, 0, 0), "stack_on_door")
			current_action = "hold_cautious"
			_maybe_open_nearby()
			return
		if hostile_room_a and stance != Stance.CAUTIOUS:
			set_goal(_marker("room_a"), "clear_room_a")
	_maybe_open_nearby()
	if goal_pos.x != INF:
		if global_position.distance_to(goal_pos) <= 0.7:
			current_action = "wait"
		else:
			current_action = "move"
	_nav.target_position = goal_pos if goal_pos.x != INF else global_position
	if _nav.is_navigation_finished() == false:
		var path := _nav.get_current_navigation_path()
		if path.is_empty() and sim_time_ok():
			blocked_reason = "no_path"
			current_action = "blocked"
		else:
			blocked_reason = ""


func _decide_criminal() -> void:
	var saw_agent := false
	for f in knowledge.all_facts():
		var fact := f as KnowledgeStore.Fact
		if fact.seen_now and _is_agent_name(fact.id):
			saw_agent = true
			goal_pos = fact.last_pos
			goal_text = "engage"
			current_action = "combat"
			return
	if goal_text == "guard_door":
		current_action = "guard"
		return
	current_action = "wait"


func _maybe_open_nearby() -> void:
	for d in get_tree().get_nodes_in_group(Conventions.GROUP_DOORS):
		if not (d is Door):
			continue
		var door := d as Door
		if door.is_open or door.busy:
			continue
		if global_position.distance_to(door.global_position) < 1.35:
			if _facing_or_path_blocked():
				door.request_open(self)


func _facing_or_path_blocked() -> bool:
	if blocked_reason == "no_path":
		return true
	if _nav.is_navigation_finished():
		return false
	var next := _nav.get_next_path_position()
	var ahead := PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 0.9, 0),
		global_position + Vector3(0, 0.9, 0) + (-transform.basis.z) * 1.4
	)
	ahead.collision_mask = Conventions.LAYER_DOORS
	ahead.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(ahead)
	return not hit.is_empty() or global_position.distance_to(next) < 0.05


func _move(delta: float) -> void:
	if downed or current_action in ["wait", "guard", "hold_cautious", "downed", "blocked"]:
		if current_action != "blocked" and current_action != "hold_cautious":
			velocity.x = 0
			velocity.z = 0
		velocity.y -= 20.0 * delta
		move_and_slide()
		return
	if goal_pos.x == INF:
		return
	_nav.target_position = goal_pos
	if _nav.is_navigation_finished():
		current_action = "wait"
		velocity = Vector3(0, velocity.y, 0)
		move_and_slide()
		return
	var next := _nav.get_next_path_position()
	var dir := next - global_position
	dir.y = 0
	if dir.length() > 0.05:
		dir = dir.normalized()
		var look := global_position + dir
		look_at(Vector3(look.x, global_position.y, look.z), Vector3.UP)
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
	velocity.y -= 20.0 * delta
	move_and_slide()


func _try_shoot() -> void:
	if downed or fire_cd > 0.0:
		return
	if faction == Faction.CIVILIAN:
		return
	if stance == Stance.STEALTH and faction == Faction.AGENT:
		return
	var target := _visible_enemy()
	if target == null:
		return
	if global_position.distance_to(target.global_position) > fire_range:
		return
	fire_cd = 0.85 if faction == Faction.CRIMINAL else 0.95
	current_action = "combat"
	_emit_sound("gunshot", 14.0)
	target.take_hit(50.0, self)
	_flash()


func _try_radio() -> void:
	if faction != Faction.AGENT or downed:
		return
	if _time() - last_radio_time < 4.0:
		return
	if not knowledge.knows_hostile_in("room_a") and not _any_hostile_seen():
		return
	last_radio_time = _time()
	var host := get_tree().get_first_node_in_group("sim")
	if host and host.has_method("do_radio"):
		host.call("do_radio", self)


func take_hit(amount: float, _from: Pawn) -> void:
	if downed:
		return
	hp -= amount
	_emit_sound("impact", 6.0)
	if hp <= 0.0:
		hp = 0.0
		downed = true
		current_action = "downed"
		goal_text = "incapacitated"
		collision_layer = 0
		downed_changed.emit(self)
		var mat := _mesh.material_override as StandardMaterial3D
		if mat:
			mat.albedo_color = Color(0.35, 0.35, 0.35)


func _visible_enemy() -> Pawn:
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_PAWNS):
		if p == self or not (p is Pawn):
			continue
		var other := p as Pawn
		if other.downed:
			continue
		if not _is_enemy(other):
			continue
		if _can_see(other):
			return other
	return null


func _can_see(other: Pawn) -> bool:
	var eye := _eye.global_position
	var chest := other.global_position + Vector3(0, 1.3, 0)
	var to := chest - eye
	var dist := to.length()
	if dist > vision_range or dist < 0.05:
		return false
	var fwd := -global_transform.basis.z
	if fwd.angle_to(to.normalized()) > deg_to_rad(vision_fov * 0.5):
		return false
	var q := PhysicsRayQueryParameters3D.create(eye, chest)
	q.collision_mask = Conventions.LAYER_WORLD | Conventions.LAYER_DOORS
	q.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	return hit.is_empty()


func _is_enemy(other: Pawn) -> bool:
	if faction == Faction.AGENT:
		return other.faction == Faction.CRIMINAL
	if faction == Faction.CRIMINAL:
		return other.faction == Faction.AGENT
	return false


func _is_agent_name(id: String) -> bool:
	return id.begins_with("Agent")


func _any_hostile_seen() -> bool:
	for f in knowledge.all_facts():
		var fact := f as KnowledgeStore.Fact
		if fact.seen_now and not _is_agent_name(fact.id) and fact.id != display_name:
			if fact.id.begins_with("Criminal"):
				return true
	return false


func _room_of(pos: Vector3) -> String:
	if pos.x < -4.2 and pos.z > 14.0 and pos.z < 22.2:
		return "room_a"
	if pos.x > 10.0 and pos.z > 14.0 and pos.z < 22.2:
		return "room_b"
	if pos.z < 5.0:
		return "entrance"
	if pos.z < 14.0:
		return "corridor"
	if pos.z > 24.5:
		return "exit"
	return "central"


func _marker(key: String) -> Vector3:
	var host := get_tree().get_first_node_in_group("sim")
	if host and host.has_method("marker"):
		return host.call("marker", key)
	return global_position


func _find_named(n: String) -> Pawn:
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_PAWNS):
		if p is Pawn and (p as Pawn).display_name == n:
			return p
	return null


func _bus_sounds() -> Array:
	var host := get_tree().get_first_node_in_group("sim")
	if host and host.has_method("recent_sounds"):
		return host.call("recent_sounds")
	return []


func _emit_sound(kind: String, radius: float) -> void:
	var host := get_tree().get_first_node_in_group("sim")
	if host and host.has_method("emit_sound"):
		host.call("emit_sound", global_position, radius, kind, display_name)


func _flash() -> void:
	var light := OmniLight3D.new()
	light.light_color = Color(1, 0.85, 0.4)
	light.light_energy = 4.0
	light.omni_range = 3.0
	light.position = Vector3(0, 1.4, -0.4)
	add_child(light)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(light):
		light.queue_free()


func _time() -> float:
	var host := get_tree().get_first_node_in_group("sim")
	if host:
		return float(host.get("sim_time"))
	return Time.get_ticks_msec() * 0.001


func sim_time_ok() -> bool:
	return _time() > 0.5


func _update_label() -> void:
	_label.text = display_name
	if downed:
		_label.text += " [DOWN]"
		_label.modulate = Color(0.5, 0.5, 0.5)
	elif DebugMode.enabled:
		_label.text += "\n" + current_action


func debug_text() -> String:
	return "%s\nfaction:%s\nhp:%.0f\ngoal:%s\naction:%s\nstance:%s\n%s\n%s" % [
		display_name,
		Faction.keys()[faction],
		hp,
		goal_text,
		current_action,
		Stance.keys()[stance],
		blocked_reason,
		knowledge.debug_lines()
	]


func snapshot() -> Dictionary:
	var facts: Array = []
	for f in knowledge.all_facts():
		var fact := f as KnowledgeStore.Fact
		facts.append({
			"id": fact.id,
			"pos": fact.last_pos,
			"time": fact.last_time,
			"source": fact.source,
			"seen": fact.seen_now,
			"room": fact.room_hint
		})
	return {
		"xform": global_transform,
		"hp": hp,
		"downed": downed,
		"goal_pos": goal_pos,
		"goal_text": goal_text,
		"stance": stance,
		"caution": caution,
		"priority_civilian": priority_civilian,
		"facts": facts
	}


func apply_snapshot(data: Dictionary) -> void:
	global_transform = data["xform"]
	hp = data["hp"]
	downed = data["downed"]
	goal_pos = data["goal_pos"]
	goal_text = data["goal_text"]
	stance = data["stance"]
	caution = data["caution"]
	priority_civilian = data["priority_civilian"]
	collision_layer = 0 if downed else Conventions.LAYER_CHARACTERS
	knowledge = KnowledgeStore.new()
	for f in data["facts"]:
		var fact := KnowledgeStore.Fact.new()
		fact.id = f["id"]
		fact.last_pos = f["pos"]
		fact.last_time = f["time"]
		fact.source = f["source"]
		fact.seen_now = f["seen"]
		fact.room_hint = f["room"]
		knowledge._facts[fact.id] = fact
	if not downed and goal_pos.x != INF:
		_nav.target_position = goal_pos


func reset_spawn() -> void:
	global_transform = spawn_xform
	hp = max_hp
	downed = false
	collision_layer = Conventions.LAYER_CHARACTERS
	knowledge = KnowledgeStore.new()
	last_radio_time = -999.0
	fire_cd = 0.0
	blocked_reason = ""
	current_action = "idle"
	if spawn_goal.x != INF:
		set_goal(spawn_goal, spawn_goal_text)
