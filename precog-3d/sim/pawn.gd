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
var patrol: Array = []
var patrol_i: int = 0
var patrol_wait: float = 0.0
var look_at_pos: Vector3 = Vector3.INF
var _waypoints: Array = []
var _wp_i: int = 0
var _watch_door: Vector3 = Vector3.INF
var _investigate_pos: Vector3 = Vector3.INF
var _alert_pos: Vector3 = Vector3.INF
var _alert_until: float = 0.0
var _alert_src: String = ""
var _stuck_t: float = 0.0
var _unstuck_left: float = 0.0
var _unstuck_dir: Vector3 = Vector3.FORWARD
var _detour_pos: Vector3 = Vector3.INF
var _stuck_at: Vector3 = Vector3.ZERO
var _follow_side: int = 0
var _follow_left: float = 0.0
var _repath_t: float = 0.0

var _nav: NavigationAgent3D
var _label: Label3D
var _mesh: MeshInstance3D
var _face: MeshInstance3D
var _eye: Marker3D
var _col_shape: CollisionShape3D
var _death_seq: int = 0
var _shards: Array = []
var _shard_vel: Array = []

const OPEN_RANGE := 3.4
const BODY_RADIUS := 0.36

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
	_set_alive_collision(true)
	_build_visual()
	_nav = NavigationAgent3D.new()
	_nav.path_desired_distance = 0.4
	_nav.target_desired_distance = 0.7
	_nav.radius = 0.42
	_nav.avoidance_enabled = false
	add_child(_nav)
	floor_snap_length = 0.3
	safe_margin = 0.1
	floor_max_angle = deg_to_rad(50.0)


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
	_col_shape = CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = BODY_RADIUS
	shape.height = 1.7
	_col_shape.shape = shape
	_col_shape.position = Vector3(0, 0.9, 0)
	add_child(_col_shape)
	_label = Label3D.new()
	_label.text = display_name
	_label.position = Vector3(0, 2.05, 0)
	_label.font_size = 36
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(_label)
	_eye = Marker3D.new()
	_eye.position = Vector3(0, 1.55, 0)
	add_child(_eye)
	_face = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.18, 0.08, 0.18)
	_face.mesh = box
	_face.position = Vector3(0, 1.55, -0.28)
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color(0.95, 0.95, 0.9)
	_face.material_override = fm
	add_child(_face)


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
	_detour_pos = Vector3.INF
	_stuck_t = 0.0
	if spawn_goal.x == INF and pos.x != INF:
		spawn_goal = pos
		spawn_goal_text = text
	if _nav != null and not downed and pos.x != INF:
		_nav.target_position = pos


func setup_patrol(points: Array, watch: Vector3 = Vector3.INF) -> void:
	patrol = points.duplicate()
	patrol_i = 0
	patrol_wait = 0.0
	_watch_door = watch
	goal_text = "patrol"
	if patrol.size() > 0:
		goal_pos = patrol[0]
		if spawn_goal.x == INF:
			spawn_goal = patrol[0]
			spawn_goal_text = "patrol"
		if _nav != null:
			_nav.target_position = patrol[0]
		if watch.x != INF:
			face_xz(watch)


func set_action(text: String) -> void:
	current_action = text


func face_xz(target: Vector3) -> void:
	var to := Vector3(target.x - global_position.x, 0.0, target.z - global_position.z)
	if to.length_squared() < 0.0004:
		return
	global_basis = Basis.looking_at(to, Vector3.UP)


func _physics_process(delta: float) -> void:
	if downed:
		_update_shards(delta)
		velocity = Vector3.ZERO
		return
	if not _sim_running():
		velocity = Vector3.ZERO
		return
	fire_cd = maxf(0.0, fire_cd - delta)
	if patrol_wait > 0.0:
		patrol_wait = maxf(0.0, patrol_wait - delta)
	_sense()
	_decide()
	if look_at_pos.x != INF and current_action in ["wait", "alert_look", "guard"]:
		face_xz(look_at_pos)
	_try_open_doors()
	_move(delta)
	_try_shoot()
	_try_radio()
	_update_label()


func _sim_running() -> bool:
	var host := get_tree().get_first_node_in_group("sim")
	return host != null and bool(host.get("running"))


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
		if typeof(ev) != TYPE_DICTIONARY:
			continue
		var evd: Dictionary = ev
		var ev_pos: Vector3 = evd["pos"]
		var ev_radius: float = float(evd["radius"])
		var dist: float = global_position.distance_to(ev_pos)
		if dist <= ev_radius:
			var kind := str(evd["kind"])
			if kind == "door":
				if faction == Faction.CRIMINAL:
					_on_heard_door(ev_pos)
				elif faction == Faction.AGENT:
					look_at_pos = ev_pos
					face_xz(ev_pos)
					_alert_pos = ev_pos
					_alert_until = now + 3.5
					_alert_src = "door"
				continue
			if kind == "gunshot":
				if str(evd["src"]) == display_name:
					continue
				knowledge.hear(str(evd["src"]), ev_pos, now)
				if faction == Faction.CRIMINAL:
					_on_heard_gunshot(ev_pos)
				elif faction == Faction.AGENT:
					look_at_pos = ev_pos
					face_xz(ev_pos)
					_alert_pos = ev_pos
					_alert_until = now + 6.0
					_alert_src = str(evd["src"])
				elif faction == Faction.CIVILIAN:
					look_at_pos = ev_pos
					face_xz(ev_pos)
					goal_text = "seek_agents"
					_investigate_pos = ev_pos
				continue
			var noisy: Vector3 = ev_pos + Vector3(randf_range(-1.2, 1.2), 0.0, randf_range(-1.2, 1.2)) * (dist / maxf(ev_radius, 0.1))
			knowledge.hear(str(evd["src"]), noisy, now)


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


func _decide_civilian() -> void:
	var agent := _nearest_seen_agent()
	if agent == null:
		agent = _nearest_known_agent()
	if agent != null:
		goal_text = "stay_with_agents"
		var fwd := -agent.global_transform.basis.z
		fwd.y = 0.0
		if fwd.length_squared() < 0.0001:
			fwd = Vector3(0, 0, -1)
		else:
			fwd = fwd.normalized()
		var trail: Vector3 = agent.global_position - fwd * 1.2
		var d := global_position.distance_to(agent.global_position)
		var blocking := _blocking_followed(agent)
		if d > 1.7 or blocking:
			goal_pos = trail
			current_action = "move"
			look_at_pos = Vector3.INF
		else:
			current_action = "wait"
			look_at_pos = agent.global_position
			face_xz(look_at_pos)
		if _nav != null and goal_pos.x != INF:
			_nav.target_position = _move_target()
		return
	if goal_text == "seek_agents" and _investigate_pos.x != INF:
		if global_position.distance_to(_investigate_pos) <= 1.0:
			current_action = "wait"
			look_at_pos = _investigate_pos
			return
		goal_pos = _investigate_pos
		current_action = "move"
		if _nav != null:
			_nav.target_position = goal_pos
		return
	current_action = "wait"


func _blocking_followed(agent: Pawn) -> bool:
	if agent.goal_pos.x == INF:
		return false
	var ag := Vector3(agent.goal_pos.x - agent.global_position.x, 0.0, agent.goal_pos.z - agent.global_position.z)
	if ag.length_squared() < 0.04:
		return false
	ag = ag.normalized()
	var ac := Vector3(global_position.x - agent.global_position.x, 0.0, global_position.z - agent.global_position.z)
	if ac.length() > 2.1:
		return false
	return ac.dot(ag) > 0.15


func _nearest_seen_agent() -> Pawn:
	var best: Pawn = null
	var best_d := 9999.0
	for f in knowledge.all_facts():
		var fact := f as KnowledgeStore.Fact
		if not fact.seen_now or not _is_agent_name(fact.id):
			continue
		var p := _find_named(fact.id)
		if p == null or p.downed:
			continue
		var d := global_position.distance_to(p.global_position)
		if d < best_d:
			best_d = d
			best = p
	return best


func _nearest_known_agent() -> Pawn:
	var best: Pawn = null
	var best_d := 9999.0
	for f in knowledge.all_facts():
		var fact := f as KnowledgeStore.Fact
		if not _is_agent_name(fact.id):
			continue
		var p := _find_named(fact.id)
		if p == null or p.downed:
			continue
		var d := global_position.distance_to(fact.last_pos)
		if d < best_d:
			best_d = d
			best = p
	return best


func _decide_agent() -> void:
	var vis := _visible_enemy()
	if vis != null:
		goal_text = "engage"
		goal_pos = vis.global_position
		current_action = "combat"
		look_at_pos = vis.global_position
		face_xz(look_at_pos)
		return
	if _known_live_in("room_a"):
		if goal_text != "flank_room_a":
			_detour_pos = Vector3.INF
			_stuck_t = 0.0
		goal_text = "flank_room_a"
		var is_b := display_name == Conventions.AGENT_B
		goal_pos = _marker("room_a_north") + Vector3(1.1 if is_b else -0.45, 0.0, 0.0)
		if global_position.distance_to(goal_pos) <= 0.9:
			_hold_north_gap()
		else:
			current_action = "move"
		if _nav != null:
			_nav.target_position = _move_target()
		return
	if not priority_civilian and _known_live_in("room_b"):
		goal_text = "clear_room_b"
		var is_b2 := display_name == Conventions.AGENT_B
		goal_pos = _marker("room_b_north") + Vector3(0.4 if is_b2 else -0.35, 0.0, 0.0)
		if global_position.distance_to(goal_pos) <= 0.9:
			current_action = "wait"
			look_at_pos = _marker("room_b")
			face_xz(look_at_pos)
		else:
			current_action = "move"
		if _nav != null:
			_nav.target_position = _move_target()
		return
	if _alert_src.begins_with("Criminal") and _time() < _alert_until and _alert_pos.x != INF:
		goal_text = "check_contact"
		goal_pos = _alert_pos
		look_at_pos = _alert_pos
		if global_position.distance_to(_alert_pos) <= 1.2:
			current_action = "wait"
			face_xz(look_at_pos)
		else:
			current_action = "move"
		if _nav != null:
			_nav.target_position = _move_target()
		return
	var hunt := _nearest_known_live_criminal_pos()
	if hunt.x != INF:
		goal_text = "hunt"
		goal_pos = hunt
		current_action = "move"
		look_at_pos = hunt
		if _nav != null:
			_nav.target_position = _move_target()
		return
	if not _ready_to_extract():
		_pursue_room_a()
		return
	_extract_step()


func _ready_to_extract() -> bool:
	if _known_live_criminal():
		return false
	var c1 := _find_named(Conventions.CRIMINAL_1)
	if c1 and c1.downed:
		return true
	var civ := _find_named(Conventions.CIVILIAN)
	if civ and not civ.downed and global_position.distance_to(civ.global_position) < 3.2:
		return true
	return _room_of(global_position) == "room_a"


func _known_live_criminal() -> bool:
	return _nearest_known_live_criminal_pos().x != INF


func _nearest_known_live_criminal_pos() -> Vector3:
	var best := Vector3.INF
	var best_d := 9999.0
	for f in knowledge.all_facts():
		var fact := f as KnowledgeStore.Fact
		if not fact.id.begins_with("Criminal"):
			continue
		var p := _find_named(fact.id)
		if p != null and p.downed:
			continue
		var d := global_position.distance_to(fact.last_pos)
		if d < best_d:
			best_d = d
			best = fact.last_pos
	return best


func _pursue_room_a() -> void:
	goal_text = "reach_room_a"
	goal_pos = _marker("room_a")
	if global_position.distance_to(goal_pos) <= 0.8:
		current_action = "wait"
	else:
		current_action = "move"
	if _nav != null:
		_nav.target_position = goal_pos


func _known_live_in(room: String) -> bool:
	for f in knowledge.all_facts():
		var fact := f as KnowledgeStore.Fact
		if fact.room_hint != room or not fact.id.begins_with("Criminal"):
			continue
		var p := _find_named(fact.id)
		if p == null or not p.downed:
			return true
	return false


func _begin_flank_room_a() -> void:
	# Navmesh ignores closed doors, so the first targets must sit north of
	# Central. Otherwise agents path through Door A and stack on the panel.
	var is_b := display_name == Conventions.AGENT_B
	var lat := 0.35 if is_b else -0.35
	var along := 0.25 if is_b else 0.0
	_waypoints = [
		_marker("central_north") + Vector3(lat, 0.0, along),
		_marker("north_hall") + Vector3(lat, 0.0, 0.0),
		_marker("room_a_north") + Vector3(1.2 if is_b else -0.45, 0.0, -0.12 if is_b else 0.18)
	]
	_wp_i = 0
	goal_text = "flank_room_a"
	goal_pos = _waypoints[0]
	current_action = "move"
	look_at_pos = Vector3.INF
	if _nav != null:
		_nav.target_position = goal_pos


func _follow_waypoints() -> void:
	if _waypoints.is_empty():
		if goal_text == "flank_room_a":
			_begin_flank_room_a()
		elif goal_text == "clear_room_b":
			_begin_clear_room_b()
		elif goal_text == "extract":
			_begin_extract()
		else:
			return
	if goal_text == "flank_room_a" and _near_closed_door_a() and _wp_i < 2:
		_wp_i = 0
	if _wp_i < _waypoints.size():
		var tgt: Vector3 = _waypoints[_wp_i]
		if global_position.distance_to(tgt) <= 0.85:
			_wp_i += 1
			if _wp_i < _waypoints.size():
				goal_pos = _waypoints[_wp_i]
				current_action = "move"
			else:
				_waypoints_done()
			return
		goal_pos = tgt
		current_action = "move"
		if _nav != null:
			_nav.target_position = goal_pos
		return
	_waypoints_done()


func _waypoints_done() -> void:
	if goal_text == "flank_room_a":
		_hold_north_gap()
		return
	if goal_text == "clear_room_b":
		current_action = "wait"
		look_at_pos = _marker("room_b")
		face_xz(look_at_pos)
		goal_pos = global_position
		return
	if goal_text == "extract":
		current_action = "wait"
		look_at_pos = _marker("exit")
		return
	current_action = "wait"


func _begin_clear_room_b() -> void:
	var is_b := display_name == Conventions.AGENT_B
	var lat := 0.35 if is_b else -0.35
	_waypoints = [
		_marker("north_hall") + Vector3(lat, 0.0, 0.0),
		_marker("room_b_north") + Vector3(lat, 0.0, 0.0)
	]
	_wp_i = 0
	goal_text = "clear_room_b"
	goal_pos = _waypoints[0]
	current_action = "move"
	look_at_pos = Vector3.INF
	if _nav != null:
		_nav.target_position = goal_pos


func _begin_extract() -> void:
	var is_b := display_name == Conventions.AGENT_B
	var lat := 0.4 if is_b else -0.45
	_waypoints = [
		_marker("room_a_north") + Vector3(lat, 0.0, 0.0),
		_marker("north_hall") + Vector3(lat, 0.0, 0.0),
		_marker("exit") + Vector3(lat * 0.3, 0.0, 0.0)
	]
	_wp_i = 0
	var best_i := 0
	var best_d := 9999.0
	for i in _waypoints.size():
		var d: float = global_position.distance_to(_waypoints[i])
		if d < best_d:
			best_d = d
			best_i = i
	_wp_i = best_i
	if global_position.distance_to(_waypoints[_wp_i]) <= 0.9 and _wp_i < _waypoints.size() - 1:
		_wp_i += 1
	goal_text = "extract"
	goal_pos = _waypoints[_wp_i]
	current_action = "move"
	look_at_pos = Vector3.INF
	if _nav != null:
		_nav.target_position = goal_pos


func _extract_step() -> void:
	goal_text = "extract"
	var is_b := display_name == Conventions.AGENT_B
	var rally: Vector3 = _marker("room_a_north") + Vector3(0.4 if is_b else -0.45, 0.0, 0.0)
	var civ := _find_named(Conventions.CIVILIAN)
	if civ and not civ.downed and global_position.distance_to(civ.global_position) > 2.8:
		goal_pos = rally
		if global_position.distance_to(rally) > 0.95:
			current_action = "move"
		else:
			current_action = "wait"
			look_at_pos = _marker("central")
			face_xz(look_at_pos)
		if _nav != null:
			_nav.target_position = _move_target()
		return
	if global_position.z < 22.5:
		goal_pos = rally
		current_action = "move"
		if _nav != null:
			_nav.target_position = _move_target()
		return
	goal_pos = _marker("exit") + Vector3(0.35 if is_b else -0.35, 0.0, 0.0)
	if global_position.distance_to(goal_pos) <= 0.9:
		current_action = "wait"
		look_at_pos = goal_pos
	else:
		current_action = "move"
	if _nav != null:
		_nav.target_position = _move_target()


func _near_closed_door_a() -> bool:
	var opening := _marker("door_a")
	return global_position.distance_to(Vector3(opening.x, global_position.y, opening.z)) < 2.4


func _hold_north_gap() -> void:
	current_action = "wait"
	var known := knowledge.last_pos_in("room_a")
	if _alert_pos.x != INF and _time() < _alert_until:
		look_at_pos = _alert_pos
	elif known.x == INF:
		look_at_pos = _marker("room_a")
	else:
		look_at_pos = known
	face_xz(look_at_pos)
	goal_pos = global_position
	if _nav != null:
		_nav.target_position = global_position


func _decide_criminal() -> void:
	for f in knowledge.all_facts():
		var fact := f as KnowledgeStore.Fact
		if fact.seen_now and _is_agent_name(fact.id):
			goal_pos = fact.last_pos
			goal_text = "engage"
			current_action = "combat"
			look_at_pos = fact.last_pos
			_investigate_pos = fact.last_pos
			return
	if patrol_wait > 0.0:
		current_action = "alert_look" if look_at_pos.x != INF else "wait"
		return
	if goal_text == "investigate" and _investigate_pos.x != INF:
		if global_position.distance_to(_investigate_pos) <= 1.1:
			current_action = "alert_look"
			look_at_pos = _investigate_pos
			return
		goal_pos = _investigate_pos
		current_action = "move"
		look_at_pos = Vector3.INF
		if _nav != null:
			_nav.target_position = _move_target()
		return
	if patrol.size() > 0:
		var tgt: Vector3 = patrol[patrol_i]
		if global_position.distance_to(tgt) <= 0.65:
			patrol_wait = 1.7
			look_at_pos = _watch_door if _watch_door.x != INF else tgt
			patrol_i = (patrol_i + 1) % patrol.size()
			current_action = "wait"
			return
		goal_pos = tgt
		goal_text = "patrol"
		current_action = "move"
		look_at_pos = Vector3.INF
		if _nav != null:
			_nav.target_position = goal_pos
		return
	current_action = "wait"


func _on_heard_door(pos: Vector3) -> void:
	if current_action == "combat" or goal_text == "investigate" or goal_text == "engage":
		return
	look_at_pos = pos
	face_xz(pos)
	patrol_wait = 2.4
	current_action = "alert_look"
	goal_text = "check_door"


func _on_heard_gunshot(pos: Vector3) -> void:
	if current_action == "combat":
		return
	if global_position.distance_to(pos) < 1.4:
		return
	_investigate_pos = pos
	look_at_pos = pos
	face_xz(pos)
	patrol_wait = 0.35
	current_action = "alert_look"
	goal_text = "investigate"
	goal_pos = pos


func _try_open_doors() -> void:
	if downed or current_action in ["guard", "downed", "hold_cautious"]:
		return
	if current_action == "wait" and goal_text != "reach_room_a" and goal_text != "extract":
		return
	if faction == Faction.CRIMINAL and goal_text != "investigate" and goal_text != "engage":
		return
	if faction == Faction.CIVILIAN and current_action != "move":
		return
	if faction == Faction.AGENT and current_action == "alert_look":
		return
	for d in get_tree().get_nodes_in_group(Conventions.GROUP_DOORS):
		if not (d is Door):
			continue
		var door := d as Door
		if door.is_open:
			continue
		if not _may_open_door(door):
			continue
		if not _needs_this_door(door):
			continue
		if door.xz_distance_to(global_position) > OPEN_RANGE:
			continue
		current_action = "open_door"
		door.request_open(self)
		return


func _needs_this_door(door: Door) -> bool:
	if door.busy:
		return true
	var opening := door.opening_position()
	if abs(global_position.z - opening.z) > 2.8:
		return false
	if goal_pos.x != INF:
		var pawn_side := signf(global_position.x - opening.x)
		var goal_side := signf(goal_pos.x - opening.x)
		if pawn_side != 0.0 and goal_side != 0.0 and pawn_side != goal_side:
			return true
	var aim := _aim_point()
	var aim_side := signf(aim.x - opening.x)
	var pawn_side2 := signf(global_position.x - opening.x)
	if pawn_side2 != 0.0 and aim_side != 0.0 and pawn_side2 != aim_side:
		return true
	var to_door := Vector2(opening.x - global_position.x, opening.z - global_position.z)
	var to_aim := Vector2(aim.x - global_position.x, aim.z - global_position.z)
	if to_door.length_squared() < 0.0001:
		return true
	if to_aim.length_squared() > 0.01 and to_aim.dot(to_door) > 0.0:
		return true
	return _ray_hits_door(door)


func _aim_point() -> Vector3:
	if _nav != null:
		var rid := _nav.get_navigation_map()
		if rid != RID() and NavigationServer3D.map_get_iteration_id(rid) != 0 and not _nav.is_navigation_finished():
			return _nav.get_next_path_position()
	if goal_pos.x != INF:
		return goal_pos
	return global_position + (-global_transform.basis.z)


func _ray_hits_door(door: Door) -> bool:
	var from := global_position + Vector3(0, 0.9, 0)
	var to := from + (-global_transform.basis.z) * 2.0
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.collision_mask = Conventions.LAYER_DOORS
	q.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return false
	return _as_door(hit.collider) == door


func _as_door(n: Object) -> Door:
	var cur: Node = n as Node
	while cur:
		if cur is Door:
			return cur as Door
		cur = cur.get_parent()
	return null


func _move(delta: float) -> void:
	if downed or current_action in ["wait", "guard", "hold_cautious", "downed", "blocked", "open_door", "alert_look"]:
		_stuck_t = 0.0
		velocity.x = 0
		velocity.z = 0
		velocity.y -= 20.0 * delta
		move_and_slide()
		return
	if goal_pos.x == INF:
		return
	_repath_t = maxf(0.0, _repath_t - delta)
	if _unstuck_left > 0.0:
		_unstuck_left -= delta
		_apply_move(_unstuck_dir, delta)
		return
	if global_position.distance_to(goal_pos) <= 0.72 and not _los_hard_blocked(global_position, goal_pos):
		_detour_pos = Vector3.INF
		_follow_side = 0
		velocity.x = 0
		velocity.z = 0
		velocity.y -= 20.0 * delta
		move_and_slide()
		return
	var dir := _steer_space(_seek_dir(), delta)
	if dir.length() > 0.05:
		if current_action != "combat":
			face_xz(global_position + dir)
		_apply_move(dir, delta)
	else:
		velocity.x = 0
		velocity.z = 0
		velocity.y -= 20.0 * delta
		move_and_slide()
	_update_stuck(delta)


func _apply_move(dir: Vector3, delta: float) -> void:
	dir.y = 0.0
	if dir.length_squared() > 0.0001:
		dir = dir.normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
	else:
		velocity.x = 0
		velocity.z = 0
	velocity.y -= 20.0 * delta
	move_and_slide()


func _move_target() -> Vector3:
	if goal_pos.x == INF:
		return global_position
	if _detour_pos.x != INF:
		if global_position.distance_to(_detour_pos) <= 0.85 or _los_hard_blocked(global_position, _detour_pos):
			_detour_pos = Vector3.INF
		else:
			return _detour_pos
	if _los_hard_blocked(global_position, goal_pos):
		if _repath_t <= 0.0:
			_repath_t = 0.28
			var det := _sample_detour(goal_pos)
			if det.x != INF:
				_detour_pos = det
				return det
		elif _detour_pos.x != INF:
			return _detour_pos
	else:
		_detour_pos = Vector3.INF
	return goal_pos


func _seek_dir() -> Vector3:
	var dest := _move_target()
	var to_dest := Vector3(dest.x - global_position.x, 0.0, dest.z - global_position.z)
	if _nav != null:
		_nav.target_position = dest
		var rid := _nav.get_navigation_map()
		if rid != RID() and NavigationServer3D.map_get_iteration_id(rid) != 0:
			if not _nav.is_navigation_finished():
				var next := _nav.get_next_path_position()
				var to_next := Vector3(next.x - global_position.x, 0.0, next.z - global_position.z)
				var step_len := to_next.length()
				if step_len > 0.08:
					to_next = to_next / step_len
					if not _step_hard_blocked(to_next, minf(step_len, 1.35)):
						return to_next
	if to_dest.length_squared() < 0.0025:
		return Vector3.ZERO
	return to_dest.normalized()


func _steer_space(desired: Vector3, delta: float) -> Vector3:
	if desired.length_squared() < 0.0001:
		return Vector3.ZERO
	desired = desired.normalized()
	var openable := _door_ahead(desired, OPEN_RANGE)
	if openable != null and _may_open_door(openable):
		_follow_side = 0
		if openable.xz_distance_to(global_position) <= OPEN_RANGE:
			_stuck_t = 0.0
			return Vector3.ZERO
		var to_open := openable.opening_position() - global_position
		to_open.y = 0.0
		if to_open.length_squared() > 0.01:
			return _separate(_steer_off_walls(to_open.normalized()))
		return Vector3.ZERO
	var picked := desired
	if _hard_clearance(desired, 1.25) < 0.62:
		picked = _best_local_dir(desired)
		if _hard_clearance(picked, 1.15) < 0.5:
			if _follow_side == 0:
				_follow_side = _choose_follow_side(picked)
			_follow_left = 1.8
			picked = _wall_follow_dir(picked)
		else:
			_follow_side = 0
	else:
		_follow_side = 0
		_follow_left = maxf(0.0, _follow_left - delta)
	return _separate(_steer_off_walls(picked))


func _best_local_dir(desired: Vector3) -> Vector3:
	var to_goal := desired
	if goal_pos.x != INF:
		to_goal = Vector3(goal_pos.x - global_position.x, 0.0, goal_pos.z - global_position.z)
		if to_goal.length_squared() > 0.0001:
			to_goal = to_goal.normalized()
	var best_dir := desired
	var best_score := -9999.0
	for i in 16:
		var ang := float(i) * PI / 8.0
		var cand := Vector3(sin(ang), 0.0, cos(ang))
		var cl := _hard_clearance(cand, 1.8)
		if cl < 0.48:
			continue
		var toward := cand.dot(to_goal)
		var score := toward * 3.2 + cand.dot(desired) * 1.4 + minf(cl, 1.3) * 0.35
		if toward < -0.15:
			score -= 1.6
		if score > best_score:
			best_score = score
			best_dir = cand
	return best_dir


func _choose_follow_side(desired: Vector3) -> int:
	var left := Vector3(-desired.z, 0.0, desired.x)
	var right := Vector3(desired.z, 0.0, -desired.x)
	var to_goal := Vector3.ZERO
	if goal_pos.x != INF:
		to_goal = Vector3(goal_pos.x - global_position.x, 0.0, goal_pos.z - global_position.z)
		if to_goal.length_squared() > 0.0001:
			to_goal = to_goal.normalized()
	var sl := _hard_clearance(left, 1.9) + left.dot(to_goal) * 1.35
	var sr := _hard_clearance(right, 1.9) + right.dot(to_goal) * 1.35
	return -1 if sl >= sr else 1


func _wall_follow_dir(desired: Vector3) -> Vector3:
	var hit := _cast_hard(desired, 1.35)
	var n := Vector3.ZERO
	if not hit.is_empty():
		n = hit.normal
		n.y = 0.0
	if n.length_squared() < 0.01:
		n = -desired
	else:
		n = n.normalized()
	var tangent := Vector3(n.z, 0.0, -n.x) if _follow_side > 0 else Vector3(-n.z, 0.0, n.x)
	if tangent.length_squared() < 0.0001:
		tangent = Vector3(-desired.z, 0.0, desired.x) if _follow_side < 0 else Vector3(desired.z, 0.0, -desired.x)
	tangent = tangent.normalized()
	if _hard_clearance(tangent, 0.95) < 0.42:
		_follow_side = -_follow_side
		tangent = -tangent
		if _hard_clearance(tangent, 0.95) < 0.42:
			_start_unstuck()
			return _unstuck_dir
	return _steer_off_walls(tangent)


func _update_stuck(delta: float) -> void:
	if goal_pos.x == INF or global_position.distance_to(goal_pos) <= 0.9:
		_stuck_t = 0.0
		return
	var spd := Vector2(velocity.x, velocity.z).length()
	if spd < 0.24:
		_stuck_t += delta
	else:
		_stuck_t = maxf(0.0, _stuck_t - delta * 0.6)
	if _stuck_t > 0.34:
		_follow_side = -_follow_side if _follow_side != 0 else _choose_follow_side(_seek_dir())
		_start_unstuck()


func _start_unstuck() -> void:
	_stuck_t = 0.0
	_stuck_at = Vector3(global_position.x, 0.0, global_position.z)
	var to_goal := Vector3.ZERO
	if goal_pos.x != INF:
		to_goal = Vector3(goal_pos.x - global_position.x, 0.0, goal_pos.z - global_position.z)
		if to_goal.length_squared() > 0.0001:
			to_goal = to_goal.normalized()
	var fwd := -global_transform.basis.z
	fwd.y = 0.0
	if fwd.length_squared() < 0.0001:
		fwd = Vector3(0, 0, -1)
	else:
		fwd = fwd.normalized()
	var best_dir := -fwd
	var best_score := -999.0
	for i in 8:
		var ang := float(i) * PI * 0.25
		var cand := Vector3(sin(ang), 0.0, cos(ang))
		var clear := _hard_clearance(cand, 1.6)
		if clear < 0.4:
			continue
		var score := clear
		if to_goal.length_squared() > 0.0001:
			score += cand.dot(to_goal) * 0.9
		if score > best_score:
			best_score = score
			best_dir = cand
	_unstuck_dir = best_dir
	_unstuck_left = 0.48
	_repath_t = 0.0
	var local_step := global_position + best_dir * 2.6
	local_step.y = global_position.y
	_detour_pos = local_step
	var det := _sample_detour(goal_pos)
	if det.x != INF and not _los_hard_blocked(global_position, det):
		_detour_pos = det


func _may_open_door(door: Door) -> bool:
	if goal_text == "flank_room_a" and str(door.name) == "DoorA":
		return false
	return true


func _door_ahead(dir: Vector3, dist: float) -> Door:
	var hit := _cast_hard(dir, dist)
	if hit.is_empty():
		return null
	var door := _as_door(hit.collider)
	if door != null and not door.is_open:
		return door
	return null


func _cast_hard(dir: Vector3, dist: float) -> Dictionary:
	if dir.length_squared() < 0.0001:
		return {}
	var origin := global_position + Vector3(0.0, 0.9, 0.0)
	var q := PhysicsRayQueryParameters3D.create(origin, origin + dir.normalized() * dist)
	q.collision_mask = Conventions.LAYER_WORLD | Conventions.LAYER_DOORS
	q.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(q)


func _step_hard_blocked(dir: Vector3, dist: float) -> bool:
	var hit := _cast_hard(dir, dist)
	if hit.is_empty():
		return false
	return _hit_is_hard(hit)


func _los_hard_blocked(from: Vector3, to: Vector3) -> bool:
	var delta := Vector3(to.x - from.x, 0.0, to.z - from.z)
	var span := delta.length()
	if span < 0.25:
		return false
	delta = delta / span
	var a := from + Vector3(0.0, 0.9, 0.0) + delta * 0.55
	var b := to + Vector3(0.0, 0.9, 0.0)
	if a.distance_to(b) < 0.12:
		return false
	var q := PhysicsRayQueryParameters3D.create(a, b)
	q.collision_mask = Conventions.LAYER_WORLD | Conventions.LAYER_DOORS
	q.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return false
	return _hit_is_hard(hit)


func _hit_is_hard(hit: Dictionary) -> bool:
	if hit.collider is Pawn:
		return false
	var door := _as_door(hit.collider)
	if door != null:
		if door.is_open:
			return false
		return not _may_open_door(door)
	return true


func _sample_detour(final_goal: Vector3) -> Vector3:
	if final_goal.x == INF:
		return Vector3.INF
	var rid := RID()
	if _nav != null:
		rid = _nav.get_navigation_map()
	var candidates: Array = []
	var keys: Array = ["central_north", "north_hall", "room_a_north", "room_b_north", "central", "corridor"]
	for k in keys:
		candidates.append(_marker(str(k)))
	for i in 16:
		var ang := float(i) * PI / 8.0
		var cdir := Vector3(sin(ang), 0.0, cos(ang))
		candidates.append(global_position + cdir * 2.4)
		candidates.append(global_position + cdir * 4.6)
		candidates.append(global_position + cdir * 7.4)
	var block := _cast_hard(Vector3(final_goal.x - global_position.x, 0.0, final_goal.z - global_position.z), 4.0)
	if not block.is_empty():
		var n: Vector3 = block.normal
		n.y = 0.0
		if n.length_squared() > 0.01:
			n = n.normalized()
			var hitp: Vector3 = block.position
			hitp.y = global_position.y
			var tan_l := Vector3(-n.z, 0.0, n.x)
			var tan_r := Vector3(n.z, 0.0, -n.x)
			candidates.append(hitp + tan_l * 2.2)
			candidates.append(hitp + tan_r * 2.2)
			candidates.append(hitp + tan_l * 4.0)
			candidates.append(hitp + tan_r * 4.0)
			candidates.append(hitp + tan_l * 2.2 + n * 1.4)
			candidates.append(hitp + tan_r * 2.2 + n * 1.4)
	var best := Vector3.INF
	var best_score := -99999.0
	for c in candidates:
		var pt: Vector3 = c
		if rid != RID() and NavigationServer3D.map_get_iteration_id(rid) != 0:
			pt = NavigationServer3D.map_get_closest_point(rid, c)
			if pt.distance_to(c) > 1.4:
				continue
		pt.y = global_position.y
		if global_position.distance_to(pt) < 1.05:
			continue
		if _los_hard_blocked(global_position, pt):
			continue
		var sees_goal := not _los_hard_blocked(pt, final_goal)
		var score := -pt.distance_to(final_goal) - global_position.distance_to(pt) * 0.12
		if sees_goal:
			score += 80.0
		if score > best_score:
			best_score = score
			best = pt
	return best


func _hard_clearance(dir: Vector3, dist: float) -> float:
	var hit := _cast_hard(dir, dist)
	if hit.is_empty():
		return dist
	if not _hit_is_hard(hit):
		return dist
	var origin := global_position + Vector3(0.0, 0.9, 0.0)
	return origin.distance_to(hit.position)


func _clearance(dir: Vector3, dist: float) -> float:
	return _hard_clearance(dir, dist)


func _separate(dir: Vector3) -> Vector3:
	var push := Vector3.ZERO
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_PAWNS):
		if p == self or not (p is Pawn):
			continue
		var other := p as Pawn
		if other.downed:
			continue
		var to := global_position - other.global_position
		to.y = 0.0
		var d := to.length()
		if d < 0.05 or d > 1.15:
			continue
		push += to.normalized() * (1.2 - d)
	if push.length_squared() < 0.0001:
		return dir
	var steered := dir + push * 2.2
	steered.y = 0.0
	if steered.length_squared() < 0.0001:
		return dir
	return steered.normalized()


func _steer_off_walls(dir: Vector3) -> Vector3:
	var origin := global_position + Vector3(0.0, 0.9, 0.0)
	var space := get_world_3d().direct_space_state
	var mask := Conventions.LAYER_WORLD | Conventions.LAYER_DOORS
	var fwd_q := PhysicsRayQueryParameters3D.create(origin, origin + dir * 0.9)
	fwd_q.collision_mask = mask
	fwd_q.exclude = [get_rid()]
	var fwd_hit := space.intersect_ray(fwd_q)
	if not fwd_hit.is_empty() and _hit_is_hard(fwd_hit):
		var n: Vector3 = fwd_hit.normal
		n.y = 0.0
		if n.length_squared() > 0.01:
			n = n.normalized()
			var slid := dir.slide(n)
			if slid.length_squared() > 0.0004:
				dir = slid.normalized()
			else:
				dir = Vector3(-n.z, 0.0, n.x)
	var right := Vector3(-dir.z, 0.0, dir.x)
	var push := Vector3.ZERO
	var rays: Array = [right, -right, (dir + right).normalized(), (dir - right).normalized()]
	for side in rays:
		if side.length_squared() < 0.01:
			continue
		var q := PhysicsRayQueryParameters3D.create(origin, origin + side * 0.95)
		q.collision_mask = mask
		q.exclude = [get_rid()]
		var hit := space.intersect_ray(q)
		if hit.is_empty() or not _hit_is_hard(hit):
			continue
		var dist: float = origin.distance_to(hit.position)
		if dist < 0.88:
			var hn: Vector3 = hit.normal
			hn.y = 0.0
			if hn.length_squared() > 0.01:
				push += hn.normalized() * (0.88 - dist)
	var steered := dir + push * 3.0
	steered.y = 0.0
	if steered.length_squared() < 0.0001:
		return dir
	return steered.normalized()


func _try_shoot() -> void:
	if downed or fire_cd > 0.0:
		return
	if faction == Faction.CIVILIAN:
		return
	if goal_text == "flank_room_a" and global_position.z < 21.4:
		return
	var target := _visible_enemy()
	if target == null:
		return
	if global_position.distance_to(target.global_position) > fire_range:
		return
	fire_cd = 0.85 if faction == Faction.CRIMINAL else 0.95
	current_action = "combat"
	_emit_sound("gunshot", 28.0)
	target.take_hit(100.0, self)
	_flash()


func _try_radio() -> void:
	if faction != Faction.AGENT or downed:
		return
	if _time() - last_radio_time < 4.0:
		return
	if not knowledge.knows_hostile_in("room_a") and not knowledge.knows_hostile_in("room_b") and not _any_hostile_seen():
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
	if hp > 0.0:
		return
	hp = 0.0
	downed = true
	current_action = "downed"
	goal_text = "incapacitated"
	_set_alive_collision(false)
	downed_changed.emit(self)
	_death_seq += 1
	_play_death(_death_seq)


func _set_alive_collision(alive: bool) -> void:
	if alive:
		collision_layer = Conventions.LAYER_CHARACTERS
		collision_mask = Conventions.LAYER_WORLD | Conventions.LAYER_DOORS | Conventions.LAYER_CHARACTERS
	else:
		collision_layer = 0
		collision_mask = 0
	if _col_shape:
		_col_shape.disabled = not alive


func _apply_alive_visual(alive: bool) -> void:
	_clear_shards()
	if _mesh:
		_mesh.visible = alive
		_mesh.scale = Vector3.ONE
		var mat := _mesh.material_override as StandardMaterial3D
		if mat:
			mat.albedo_color = _color()
	if _face:
		_face.visible = alive
	if _label:
		_label.visible = alive
		_label.modulate = Color.WHITE


func _play_death(seq: int) -> void:
	var mat := _mesh.material_override as StandardMaterial3D
	var base := _color()
	for i in 5:
		if seq != _death_seq:
			return
		if mat:
			mat.albedo_color = Color(1, 1, 1)
		_mesh.visible = true
		_face.visible = true
		for _n in 6:
			if seq != _death_seq:
				return
			await get_tree().physics_frame
		if seq != _death_seq:
			return
		if mat:
			mat.albedo_color = base
		_mesh.visible = false
		_face.visible = false
		for _n in 4:
			if seq != _death_seq:
				return
			await get_tree().physics_frame
	if seq != _death_seq:
		return
	_mesh.visible = false
	_face.visible = false
	_label.visible = false
	_spawn_shards()


func _spawn_shards() -> void:
	_clear_shards()
	var origin := Vector3(0.0, 0.9, 0.0)
	for i in 8:
		var shard := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.18, 0.18, 0.18)
		shard.mesh = box
		var sm := StandardMaterial3D.new()
		sm.albedo_color = _color()
		sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		shard.material_override = sm
		shard.position = origin + Vector3(randf_range(-0.2, 0.2), randf_range(-0.2, 0.4), randf_range(-0.2, 0.2))
		add_child(shard)
		_shards.append(shard)
		_shard_vel.append(Vector3(randf_range(-2.2, 2.2), randf_range(1.5, 3.2), randf_range(-2.2, 2.2)))


func _clear_shards() -> void:
	for s in _shards:
		if is_instance_valid(s):
			s.queue_free()
	_shards.clear()
	_shard_vel.clear()


func _update_shards(delta: float) -> void:
	if not _sim_running():
		return
	var i := 0
	while i < _shards.size():
		var shard: MeshInstance3D = _shards[i]
		if not is_instance_valid(shard):
			_shards.remove_at(i)
			_shard_vel.remove_at(i)
			continue
		var vel: Vector3 = _shard_vel[i]
		vel.y -= 9.0 * delta
		_shard_vel[i] = vel
		shard.position += vel * delta
		var sm := shard.material_override as StandardMaterial3D
		if sm:
			var c := sm.albedo_color
			c.a = maxf(0.0, c.a - delta * 0.9)
			sm.albedo_color = c
			if c.a <= 0.02:
				shard.queue_free()
				_shards.remove_at(i)
				_shard_vel.remove_at(i)
				continue
		i += 1


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
	if host is SimHost:
		return (host as SimHost).marker(key)
	return global_position


func _find_named(n: String) -> Pawn:
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_PAWNS):
		if p is Pawn and (p as Pawn).display_name == n:
			return p
	return null


func _bus_sounds() -> Array:
	var host := get_tree().get_first_node_in_group("sim")
	if host is SimHost:
		return (host as SimHost).recent_sounds()
	return []


func _emit_sound(kind: String, radius: float) -> void:
	var host := get_tree().get_first_node_in_group("sim")
	if host is SimHost:
		(host as SimHost).emit_sound(global_position, radius, kind, display_name)


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
	if host is SimHost:
		return (host as SimHost).sim_time
	return Time.get_ticks_msec() * 0.001


func sim_time_ok() -> bool:
	return _time() > 0.5


func _update_label() -> void:
	if not _label.visible:
		return
	_label.text = display_name
	if DebugMode.enabled:
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
		"facts": facts,
		"current_action": current_action,
		"patrol_i": patrol_i,
		"patrol_wait": patrol_wait,
		"look_at_pos": look_at_pos,
		"wp_i": _wp_i,
		"waypoints": _waypoints.duplicate(),
		"investigate_pos": _investigate_pos,
		"alert_pos": _alert_pos,
		"alert_until": _alert_until,
		"alert_src": _alert_src,
		"fire_cd": fire_cd,
		"last_radio_time": last_radio_time
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
	_death_seq += 1
	current_action = str(data.get("current_action", "idle"))
	patrol_i = int(data.get("patrol_i", 0))
	patrol_wait = float(data.get("patrol_wait", 0.0))
	look_at_pos = data.get("look_at_pos", Vector3.INF)
	_wp_i = int(data.get("wp_i", 0))
	_waypoints = data.get("waypoints", []).duplicate()
	_investigate_pos = data.get("investigate_pos", Vector3.INF)
	_alert_pos = data.get("alert_pos", Vector3.INF)
	_alert_until = float(data.get("alert_until", 0.0))
	_alert_src = str(data.get("alert_src", ""))
	fire_cd = float(data.get("fire_cd", 0.0))
	last_radio_time = float(data.get("last_radio_time", -999.0))
	_stuck_t = 0.0
	_unstuck_left = 0.0
	_detour_pos = Vector3.INF
	_follow_side = 0
	_follow_left = 0.0
	_repath_t = 0.0
	_set_alive_collision(not downed)
	_apply_alive_visual(not downed)
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
	_death_seq += 1
	patrol_i = 0
	patrol_wait = 0.0
	look_at_pos = Vector3.INF
	_waypoints.clear()
	_wp_i = 0
	_investigate_pos = Vector3.INF
	_alert_pos = Vector3.INF
	_alert_until = 0.0
	_alert_src = ""
	_stuck_t = 0.0
	_unstuck_left = 0.0
	_detour_pos = Vector3.INF
	_follow_side = 0
	_follow_left = 0.0
	_repath_t = 0.0
	_set_alive_collision(true)
	_apply_alive_visual(true)
	knowledge = KnowledgeStore.new()
	last_radio_time = -999.0
	fire_cd = 0.0
	blocked_reason = ""
	current_action = "idle"
	if spawn_goal.x != INF:
		set_goal(spawn_goal, spawn_goal_text)
