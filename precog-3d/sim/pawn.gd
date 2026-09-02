class_name Pawn
extends CharacterBody3D
## Autonomous character. Motor first, then a small mind. No player motor control.

enum Faction { AGENT, CRIMINAL, CIVILIAN }
enum Stance { CAUTIOUS, DECISIVE, STEALTH }
enum Role { NONE, SWEEPER, POSTED, HOLDER, HOSTAGE }

signal downed_changed(pawn)

const ARRIVE := 0.50
const FACE_SPEED := 0.14
const GRAVITY := 22.0

@export var display_name: String = "Pawn"
@export var faction: Faction = Faction.AGENT
@export var caution: float = 0.55
@export var move_speed: float = 3.05
@export var max_hp: float = 100.0
@export var vision_range: float = 12.0
@export var vision_fov: float = 70.0
@export var fire_range: float = 9.0

var hp: float = 100.0
var downed: bool = false
var stance: Stance = Stance.DECISIVE
var role: Role = Role.NONE
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
var anxiety: float = 0.0
var gunshots_heard: int = 0
var liberated: bool = false
var hold_name: String = ""
var post_pos: Vector3 = Vector3.INF
var check_timer: float = 0.0
var combat_enabled: bool = true
var doors_opened: int = 0
var _heard_keys: Dictionary = {}
var _door_wait: Door = null

var _nav: NavigationAgent3D
var _label: Label3D
var _mesh: MeshInstance3D
var _eye: Marker3D
var _safe_vel: Vector3 = Vector3.ZERO
var _has_safe: bool = false
var _arrived: bool = false

func _ready() -> void:
	hp = max_hp
	spawn_xform = global_transform
	add_to_group(Conventions.GROUP_PAWNS)
	if faction == Faction.AGENT:
		add_to_group(Conventions.GROUP_AGENTS)
		if role == Role.NONE:
			role = Role.SWEEPER
	elif faction == Faction.CRIMINAL:
		add_to_group(Conventions.GROUP_CRIMINALS)
	else:
		add_to_group(Conventions.GROUP_CIVILIANS)
		if role == Role.NONE:
			role = Role.HOSTAGE
	collision_layer = Conventions.LAYER_CHARACTERS
	collision_mask = Conventions.LAYER_WORLD | Conventions.LAYER_DOORS | Conventions.LAYER_CHARACTERS
	floor_snap_length = 0.35
	_build_visual()
	_build_nav()
	call_deferred("_bind_nav_map")


func _build_nav() -> void:
	_nav = NavigationAgent3D.new()
	_nav.path_desired_distance = 0.32
	_nav.target_desired_distance = ARRIVE
	_nav.radius = 0.36
	_nav.height = 1.7
	_nav.max_speed = move_speed
	_nav.avoidance_enabled = true
	_nav.use_3d_avoidance = true
	_nav.avoidance_layers = 1
	_nav.avoidance_mask = 1
	_nav.neighbor_distance = 2.4
	_nav.time_horizon_agents = 0.85
	_nav.max_neighbors = 8
	_nav.avoidance_priority = 0.55 if faction == Faction.AGENT else 0.45
	_nav.velocity_computed.connect(_on_nav_velocity)
	add_child(_nav)


func _bind_nav_map() -> void:
	if not is_inside_tree() or _nav == null:
		return
	_nav.set_navigation_map(get_world_3d().navigation_map)
	if goal_pos.x != INF:
		var dest := goal_pos
		dest.y = global_position.y
		_nav.target_position = dest


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
	shape.radius = 0.30
	shape.height = 1.65
	col.shape = shape
	col.position = Vector3(0, 0.9, 0)
	add_child(col)
	_label = Label3D.new()
	_label.text = display_name
	_label.position = Vector3(0, 2.05, 0)
	_label.font_size = 34
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
	var same := goal_pos.x != INF and goal_pos.distance_to(pos) < 0.18 and goal_text == text
	goal_pos = pos
	goal_text = text
	if spawn_goal.x == INF:
		spawn_goal = pos
		spawn_goal_text = text
	if same:
		return
	_arrived = false
	if _nav != null and not downed and pos.x != INF:
		var dest := pos
		dest.y = global_position.y
		_nav.target_position = dest


func set_action(text: String) -> void:
	current_action = text


func _on_nav_velocity(safe: Vector3) -> void:
	_safe_vel = safe
	_has_safe = true


func _physics_process(delta: float) -> void:
	if not _sim_running() or downed:
		velocity = Vector3.ZERO
		if _nav:
			_nav.set_velocity(Vector3.ZERO)
		return
	fire_cd = maxf(0.0, fire_cd - delta)
	check_timer = maxf(0.0, check_timer - delta)
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
			if faction == Faction.CRIMINAL and other.faction == Faction.CIVILIAN and other.current_action == "flee":
				_execute_hostage(other)
		else:
			knowledge.mark_lost(other.display_name)
	for ev in _bus_sounds():
		var dist := global_position.distance_to(ev.pos)
		if dist > ev.radius:
			continue
		var key := "%s_%.3f_%s" % [str(ev.src), float(ev.t), str(ev.kind)]
		if _heard_keys.has(key):
			continue
		_heard_keys[key] = true
		var noisy: Vector3 = ev.pos + Vector3(randf_range(-1.2, 1.2), 0, randf_range(-1.2, 1.2)) * (dist / maxf(ev.radius, 0.1))
		knowledge.hear(ev.src, noisy, now)
		if ev.kind == "gunshot":
			gunshots_heard += 1
			anxiety = clampf(anxiety + 0.34, 0.0, 1.0)


func _decide() -> void:
	if downed:
		current_action = "downed"
		return
	if faction == Faction.CIVILIAN:
		_decide_civilian()
		return
	if faction == Faction.CRIMINAL:
		_decide_criminal()
		return
	_decide_agent()


func _decide_agent() -> void:
	_maybe_open_nearby()
	var threat := _best_known_threat()
	if threat != null:
		set_goal(threat.global_position, "engage")
		current_action = "engage"
		return
	var stale := _stale_threat_pos()
	if stale.x != INF:
		set_goal(stale, "hunt")
		current_action = "hunt"
		return
	var civ := _find_named(Conventions.CIVILIAN)
	if civ and not civ.downed and civ.liberated:
		set_goal(_marker("exit"), "extract")
		current_action = "extract"
		return
	if civ and not civ.downed and not civ.liberated:
		if knowledge.get_fact(civ.display_name) or priority_civilian:
			set_goal(civ.global_position, "reach_civilian")
			current_action = "reach_civilian"
			return
	if knowledge.knows_hostile_in("room_a") and stance == Stance.CAUTIOUS and check_timer <= 0.0 and goal_text != "clear_room_a":
		set_goal(_marker("central") + Vector3(-1.6, 0, 0), "stack_on_door")
		current_action = "hold_cautious"
		check_timer = 1.4
		return
	if check_timer > 0.0 and current_action == "hold_cautious":
		return
	if _room_cleared_of_hostiles("room_a"):
		if civ and not civ.downed:
			set_goal(civ.global_position, "seek_civilian")
		else:
			set_goal(_marker("room_b"), "clear_room_b")
		current_action = "sweep"
		return
	set_goal(_marker("room_a"), "clear_room_a")
	current_action = "sweep"


func _decide_criminal() -> void:
	_maybe_open_nearby()
	if _should_flee():
		set_goal(_marker("exit"), "flee_exit")
		current_action = "flee"
		_maybe_open_nearby()
		return
	var saw := _visible_enemy()
	if saw:
		anxiety = clampf(anxiety + 0.2, 0.0, 1.0)
	if role == Role.HOLDER:
		_hold_on_civilian()
		current_action = "hold_hostage" if not saw else "hold_alert"
		return
	if role == Role.POSTED:
		set_goal(_post(), "hold_post")
		_face(_marker("door_a"))
		current_action = "alert_hold" if anxiety >= 0.3 or saw else "guard"
		return
	if saw:
		set_goal(saw.global_position, "engage")
		current_action = "combat"
		return
	current_action = "alert_hold" if anxiety >= 0.3 else "wait"


func _decide_civilian() -> void:
	if _is_held() and not liberated:
		if gunshots_heard >= 3:
			liberated = false
			set_goal(_marker("exit"), "flee_exit")
			current_action = "flee"
			return
		goal_pos = global_position
		goal_text = "held"
		current_action = "held"
		_arrived = true
		return
	liberated = true
	if gunshots_heard >= 3 and current_action == "flee":
		set_goal(_marker("exit"), "flee_exit")
		current_action = "flee"
		return
	var escort := _nearest_living_agent()
	if escort:
		var dest := escort.global_position
		if dest.distance_to(_marker("exit")) < 2.5:
			dest = _marker("exit")
		else:
			var away := global_position - escort.global_position
			away.y = 0.0
			if away.length() < 0.05:
				away = Vector3(0.85, 0, 0)
			if away.length() < 0.85:
				dest = escort.global_position + away.normalized() * 0.9
		set_goal(dest, "follow_agent")
		current_action = "follow"
		return
	set_goal(_marker("exit"), "extract")
	current_action = "follow"


func _hold_on_civilian() -> void:
	var civ := _find_named(hold_name) if hold_name != "" else _find_named(Conventions.CIVILIAN)
	if civ == null or civ.downed:
		hold_name = ""
		if _should_flee():
			set_goal(_marker("exit"), "flee_exit")
			current_action = "flee"
		return
	var offset := global_position - civ.global_position
	offset.y = 0.0
	if offset.length() < 0.05:
		offset = Vector3(0.9, 0, 0)
	var stand := civ.global_position + offset.normalized() * 0.95
	if global_position.distance_to(civ.global_position) > 1.35:
		set_goal(stand, "stay_on_hostage")
	else:
		goal_pos = global_position
		goal_text = "stay_on_hostage"
		_arrived = true
	_face(civ.global_position)


func _should_flee() -> bool:
	if role == Role.HOLDER:
		var civ := _find_named(hold_name) if hold_name != "" else _find_named(Conventions.CIVILIAN)
		if civ and not civ.downed:
			return false
	if role == Role.POSTED and _has_living_partner():
		return false
	if anxiety < 0.6:
		return false
	return not _has_living_partner()


func _is_held() -> bool:
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_CRIMINALS):
		if p is Pawn:
			var cr := p as Pawn
			if not cr.downed and cr.role == Role.HOLDER:
				return true
	return false


func _has_living_partner() -> bool:
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_CRIMINALS):
		if p == self or not (p is Pawn):
			continue
		if not (p as Pawn).downed:
			return true
	return false


func _best_known_threat() -> Pawn:
	var best: Pawn = null
	var best_d := 999.0
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_CRIMINALS):
		if not (p is Pawn):
			continue
		var cr := p as Pawn
		if cr.downed:
			continue
		var fact := knowledge.get_fact(cr.display_name)
		if fact == null:
			continue
		if fact.seen_now or fact.source == "precog" or fact.source == "radio":
			var d := global_position.distance_to(cr.global_position)
			if d < best_d:
				best = cr
				best_d = d
	return best


func _stale_threat_pos() -> Vector3:
	for f in knowledge.all_facts():
		var fact := f as KnowledgeStore.Fact
		if fact.id.begins_with("Criminal") and not fact.seen_now and fact.source != "none":
			var live := _find_named(fact.id)
			if live and not live.downed:
				return fact.last_pos
	return Vector3.INF


func _room_cleared_of_hostiles(_room: String) -> bool:
	return goal_text == "clear_room_a" and _arrived


func _nearest_living_agent() -> Pawn:
	var best: Pawn = null
	var best_d := 999.0
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_AGENTS):
		if p is Pawn and not (p as Pawn).downed:
			var d := global_position.distance_to((p as Pawn).global_position)
			if d < best_d:
				best = p
				best_d = d
	return best


func _post() -> Vector3:
	if post_pos.x != INF:
		return post_pos
	return _marker("post_a")


func _wants_move() -> bool:
	if downed:
		return false
	if current_action in ["wait", "guard", "alert_hold", "hold_cautious", "downed", "held", "hold_hostage", "hold_alert", "open_door", "wait_door"]:
		if current_action in ["guard", "alert_hold"]:
			var to_post := _post() - global_position
			to_post.y = 0.0
			return to_post.length() > ARRIVE
		if current_action == "hold_hostage" and goal_text == "stay_on_hostage" and _arrived:
			return false
		if current_action in ["wait", "hold_cautious", "held", "open_door", "wait_door", "hold_alert"]:
			return false
	if goal_pos.x == INF:
		return false
	var flat := goal_pos - global_position
	flat.y = 0.0
	return flat.length() > ARRIVE


func _current_speed() -> float:
	if current_action == "flee":
		return move_speed + 0.7
	if stance == Stance.STEALTH:
		return move_speed * 0.72
	if stance == Stance.CAUTIOUS:
		return move_speed * 0.86
	return move_speed


func _move(delta: float) -> void:
	velocity.y -= GRAVITY * delta
	var door := _blocking_door()
	if door != null:
		if _should_yield_door(door):
			current_action = "wait_door"
			_brake()
			move_and_slide()
			return
		current_action = "open_door"
		if not door.is_open and not door.busy:
			door.request_open(self)
			doors_opened += 1
		_door_wait = door
		_brake()
		move_and_slide()
		return
	if _door_wait != null and _door_wait.is_open:
		_door_wait = null
	if not _wants_move():
		_brake()
		move_and_slide()
		return
	var dest := goal_pos
	dest.y = global_position.y
	var to_goal := dest - global_position
	to_goal.y = 0.0
	if to_goal.length() <= ARRIVE:
		_arrived = true
		_brake()
		if current_action in ["sweep", "hunt", "engage", "seek_civilian", "reach_civilian", "extract", "follow", "flee"]:
			current_action = "wait" if current_action != "hold_hostage" else current_action
		move_and_slide()
		return
	_arrived = false
	if _nav:
		_nav.max_speed = _current_speed()
		var cur := _nav.target_position
		cur.y = dest.y
		if Vector3(cur.x, 0, cur.z).distance_to(Vector3(dest.x, 0, dest.z)) > 0.22:
			_nav.target_position = dest
	var steer := _steer_dir(to_goal)
	if steer.length() < 0.05:
		blocked_reason = "no_path"
		_brake()
		move_and_slide()
		return
	blocked_reason = ""
	var desired := steer * _current_speed()
	if _nav:
		_nav.set_velocity(desired)
	var use := desired
	if _nav and _has_safe and _safe_vel.length() > 0.05:
		use = _safe_vel
	_direct_step(use)
	move_and_slide()


func _steer_dir(to_goal: Vector3) -> Vector3:
	var fallback := to_goal.normalized() if to_goal.length() > 0.05 else Vector3.ZERO
	if _nav == null:
		return fallback if _clear_step(fallback) else Vector3.ZERO
	var path := _nav.get_current_navigation_path()
	var next := _nav.get_next_path_position()
	var via := next - global_position
	via.y = 0.0
	if path.size() >= 2 and via.length() >= 0.08:
		return via.normalized()
	if via.length() >= 0.08 and _clear_step(via):
		return via.normalized()
	if _clear_step(fallback):
		return fallback
	if path.size() >= 2 and via.length() >= 0.04:
		return via.normalized()
	return Vector3.ZERO


func _clear_step(dir: Vector3) -> bool:
	if dir.length() < 0.04:
		return false
	var space := get_world_3d().direct_space_state
	var from := global_position + Vector3.UP * 0.55
	var to := from + dir.normalized() * 0.58
	var q := PhysicsRayQueryParameters3D.create(from, to, Conventions.LAYER_WORLD)
	q.collide_with_areas = false
	q.exclude = [get_rid()]
	var hit := space.intersect_ray(q)
	if hit.is_empty():
		return true
	var n: Node = hit.get("collider")
	while n != null:
		if str(n.name).begins_with("floor_"):
			return true
		n = n.get_parent()
	return false


func _face(at: Vector3) -> void:
	var look := Vector3(at.x, global_position.y, at.z)
	if look.distance_to(global_position) < 0.08:
		return
	look_at(look, Vector3.UP)


func _direct_step(use: Vector3) -> void:
	velocity.x = use.x
	velocity.z = use.z
	if Vector3(use.x, 0, use.z).length() > FACE_SPEED:
		_face(global_position + Vector3(use.x, 0, use.z))


func _brake() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	if _nav:
		_nav.set_velocity(Vector3.ZERO)


func _blocking_door() -> Door:
	var ahead := -global_transform.basis.z
	if _nav != null:
		var next := _nav.get_next_path_position() - global_position
		next.y = 0.0
		if next.length() > 0.05:
			ahead = next.normalized()
	var from := global_position + Vector3(0, 0.9, 0)
	var q := PhysicsRayQueryParameters3D.create(from, from + ahead * 1.25)
	q.collision_mask = Conventions.LAYER_DOORS
	q.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return null
	var n: Node = hit.collider
	while n:
		if n is Door:
			var d := n as Door
			if not d.is_open:
				return d
			return null
		n = n.get_parent()
	return null


func _should_yield_door(door: Door) -> bool:
	var my_d := global_position.distance_to(door.global_position)
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_PAWNS):
		if p == self or not (p is Pawn):
			continue
		var other := p as Pawn
		if other.downed:
			continue
		if other.global_position.distance_to(door.global_position) + 0.25 < my_d:
			if other.current_action in ["open_door", "wait_door"] or other.global_position.distance_to(door.global_position) < 1.6:
				return true
	return false


func _maybe_open_nearby() -> void:
	var d := _blocking_door()
	if d:
		if not _should_yield_door(d) and not d.is_open and not d.busy:
			d.request_open(self)
			doors_opened += 1
		return
	for node in get_tree().get_nodes_in_group(Conventions.GROUP_DOORS):
		if not (node is Door):
			continue
		var door := node as Door
		if door.is_open or door.busy:
			continue
		if global_position.distance_to(door.global_position) < 1.4 and not _should_yield_door(door):
			door.request_open(self)
			doors_opened += 1


func _try_shoot() -> void:
	if not combat_enabled or downed or fire_cd > 0.0:
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


func _execute_hostage(civ: Pawn) -> void:
	if civ.downed:
		return
	civ.take_hit(200.0, self)
	var host := get_tree().get_first_node_in_group("sim")
	if host and host.has_method("log_event"):
		host.call("log_event", "hostage_killed", "%s saw the civilian flee" % display_name, display_name)


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
		collision_layer = Conventions.LAYER_CHARACTERS
		collision_mask = Conventions.LAYER_WORLD
		if _nav:
			_nav.avoidance_enabled = false
			_nav.set_velocity(Vector3.ZERO)
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
	var eye := _eye.global_position if _eye else global_position + Vector3(0, 1.55, 0)
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
		if fact.seen_now and fact.id.begins_with("Criminal"):
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


func debug_nav() -> String:
	if _nav == null:
		return "no-nav"
	var path := _nav.get_current_navigation_path()
	return "fin=%s reach=%s path=%d next=%s goal=%s pos=%s" % [
		_nav.is_navigation_finished(),
		_nav.is_target_reachable(),
		path.size(),
		_nav.get_next_path_position(),
		goal_pos,
		global_position
	]


func _role_tag() -> String:
	match role:
		Role.POSTED:
			return "POST"
		Role.HOLDER:
			return "HOLD"
		Role.HOSTAGE:
			return "CIV"
		Role.SWEEPER:
			return "AGT"
		_:
			return ""


func _update_label() -> void:
	var tag := _role_tag()
	_label.text = display_name if tag == "" else "%s [%s]" % [display_name, tag]
	if downed:
		_label.text += " [DOWN]"
		_label.modulate = Color(0.5, 0.5, 0.5)
	elif DebugMode.enabled:
		_label.text += "\n" + current_action
		_label.modulate = Color.WHITE
	else:
		_label.modulate = Color.WHITE


func debug_text() -> String:
	return "%s\nfaction:%s role:%s\nhp:%.0f anxiety:%.2f\ngoal:%s\naction:%s\nstance:%s\n%s\n%s" % [
		display_name,
		Faction.keys()[faction],
		Role.keys()[role],
		hp,
		anxiety,
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
		"role": role,
		"anxiety": anxiety,
		"gunshots_heard": gunshots_heard,
		"liberated": liberated,
		"hold_name": hold_name,
		"post_pos": post_pos,
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
	role = data.get("role", role)
	anxiety = data.get("anxiety", 0.0)
	gunshots_heard = data.get("gunshots_heard", 0)
	liberated = data.get("liberated", false)
	hold_name = data.get("hold_name", "")
	post_pos = data.get("post_pos", Vector3.INF)
	collision_layer = Conventions.LAYER_CHARACTERS
	collision_mask = Conventions.LAYER_WORLD if downed else (Conventions.LAYER_WORLD | Conventions.LAYER_DOORS | Conventions.LAYER_CHARACTERS)
	knowledge = KnowledgeStore.new()
	_heard_keys.clear()
	for f in data["facts"]:
		var fact := KnowledgeStore.Fact.new()
		fact.id = f["id"]
		fact.last_pos = f["pos"]
		fact.last_time = f["time"]
		fact.source = f["source"]
		fact.seen_now = f["seen"]
		fact.room_hint = f["room"]
		knowledge._facts[fact.id] = fact
	_arrived = false
	_has_safe = false
	if _mesh and _mesh.material_override is StandardMaterial3D:
		(_mesh.material_override as StandardMaterial3D).albedo_color = Color(0.35, 0.35, 0.35) if downed else _color()
	if _nav:
		_nav.avoidance_enabled = not downed
		if not downed and goal_pos.x != INF:
			_nav.target_position = goal_pos


func reset_spawn() -> void:
	global_transform = spawn_xform
	hp = max_hp
	downed = false
	collision_layer = Conventions.LAYER_CHARACTERS
	knowledge = KnowledgeStore.new()
	_heard_keys.clear()
	last_radio_time = -999.0
	fire_cd = 0.0
	blocked_reason = ""
	current_action = "idle"
	anxiety = 0.0
	gunshots_heard = 0
	liberated = false
	_arrived = false
	if _nav:
		_nav.avoidance_enabled = true
	if spawn_goal.x != INF:
		set_goal(spawn_goal, spawn_goal_text)
