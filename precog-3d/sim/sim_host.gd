class_name SimHost
extends Node
## Present / projection / execution loop, snapshot, radio, budget, timeline.

signal mode_changed(mode: String)
signal timeline_event(entry: Dictionary)
signal budget_changed(value: int)

enum Mode { PRESENT, PROJECTION, EXECUTION }

var running: bool = false
var mode: Mode = Mode.PRESENT
var sim_time: float = 0.0
var horizon: float = 45.0
var horizon_step: float = 45.0
var budget: int = 3
var budget_max: int = 3
var projection_index: int = 0
var last_outcome: String = ""
var geometry: LevelGeometry
var actors: Node3D
var _sounds: Array = []
var _timeline: Array = []
var _prev_timeline: Array = []
var _snapshot: Dictionary = {}
var _seed: int = 7
var committed: bool = false

func _ready() -> void:
	add_to_group("sim")
	process_priority = -10
	var sfx := preload("res://audio/sfx_player.gd").new()
	sfx.name = "Sfx"
	add_child(sfx)


func setup(geo: LevelGeometry, spawn_parent: Node3D) -> void:
	geometry = geo
	actors = spawn_parent
	_seed_rng()
	_replace_door_panels()
	_spawn_cast()
	capture_snapshot()
	running = false
	mode = Mode.PRESENT
	mode_changed.emit(mode_name())


func _seed_rng() -> void:
	seed(_seed)


func marker(key: String) -> Vector3:
	if geometry and geometry.markers.has(key):
		return geometry.markers[key]
	return Vector3.ZERO


func mode_name() -> String:
	match mode:
		Mode.PROJECTION:
			return "PROJECTION"
		Mode.EXECUTION:
			return "EXECUTION"
		_:
			return "PRESENT"


func _process(delta: float) -> void:
	if not running:
		return
	sim_time += delta
	_trim_sounds()
	if mode == Mode.PROJECTION and sim_time >= horizon:
		running = false
		log_event("horizon", "Horizon reached. Continue future or return.", "")
		mode_changed.emit(mode_name())
	_check_mission()


func start_projection() -> void:
	if mode == Mode.EXECUTION:
		return
	if mode == Mode.PROJECTION:
		if running:
			return
		horizon = sim_time + horizon_step
		running = true
		log_event("projection_start", "Continue to T+%.0fs" % horizon, "")
		mode_changed.emit(mode_name())
		return
	if running:
		running = false
		capture_snapshot()
	restore_snapshot()
	_prev_timeline = _timeline.duplicate(true)
	_timeline.clear()
	horizon = sim_time + horizon_step
	running = true
	mode = Mode.PROJECTION
	projection_index += 1
	last_outcome = ""
	_tint(Color(0.55, 0.75, 1.0))
	log_event("projection_start", "Projection %d from T+%.1fs" % [projection_index, sim_time], "")
	mode_changed.emit(mode_name())


func stop_projection(interrupted: bool) -> void:
	if mode != Mode.PROJECTION:
		return
	running = false
	mode = Mode.PRESENT
	restore_snapshot()
	_tint(Color(1, 1, 1))
	if interrupted:
		log_event("projection_cut", "Projection interrupted", "")
	mode_changed.emit(mode_name())


func play_present() -> void:
	if mode != Mode.PRESENT:
		return
	running = true
	last_outcome = ""
	log_event("present", "Present time flowing", "")
	mode_changed.emit(mode_name())


func pause_present() -> void:
	if mode != Mode.PRESENT:
		return
	if not running:
		return
	running = false
	capture_snapshot()
	log_event("present", "Present paused at T+%.1fs" % sim_time, "")
	mode_changed.emit(mode_name())


func start_execution() -> void:
	if committed:
		return
	if mode == Mode.PROJECTION:
		stop_projection(true)
	if mode == Mode.PRESENT and running:
		running = false
		capture_snapshot()
	restore_snapshot()
	_timeline.clear()
	running = true
	mode = Mode.EXECUTION
	committed = true
	horizon = sim_time + 90.0
	_tint(Color(1.0, 0.72, 0.55))
	log_event("execution", "Real operation started", "")
	mode_changed.emit(mode_name())


func capture_snapshot() -> void:
	var pawns: Dictionary = {}
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_PAWNS):
		if p is Pawn:
			pawns[(p as Pawn).display_name] = (p as Pawn).snapshot()
	var doors: Dictionary = {}
	for d in get_tree().get_nodes_in_group(Conventions.GROUP_DOORS):
		if d is Door:
			doors[d.name] = (d as Door).is_open
	_snapshot = {"pawns": pawns, "doors": doors, "budget": budget, "sim_time": sim_time, "outcome": last_outcome}


func restore_snapshot() -> void:
	if _snapshot.is_empty():
		return
	_seed_rng()
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_PAWNS):
		if p is Pawn:
			var pawn := p as Pawn
			if _snapshot["pawns"].has(pawn.display_name):
				pawn.apply_snapshot(_snapshot["pawns"][pawn.display_name])
	for d in get_tree().get_nodes_in_group(Conventions.GROUP_DOORS):
		if d is Door and _snapshot["doors"].has(d.name):
			(d as Door).abort_and_set(_snapshot["doors"][d.name])
	if _snapshot.has("sim_time"):
		sim_time = float(_snapshot["sim_time"])
	if _snapshot.has("outcome"):
		last_outcome = str(_snapshot["outcome"])
	_sounds.clear()


func emit_sound(pos: Vector3, radius: float, kind: String, src: String, write_log: bool = true) -> void:
	_sounds.append({"pos": pos, "radius": radius, "kind": kind, "src": src, "t": sim_time})
	if write_log:
		log_event(kind, "%s %s" % [src, kind], src)
	if kind == "gunshot" and has_node("Sfx"):
		get_node("Sfx").play_gunshot()


func recent_sounds() -> Array:
	return _sounds


func _trim_sounds() -> void:
	var keep: Array = []
	for s in _sounds:
		if sim_time - float(s["t"]) < 0.35:
			keep.append(s)
	_sounds = keep


func do_radio(from: Pawn) -> void:
	if from.downed:
		return
	log_event("radio", "%s radio" % from.display_name, from.display_name)
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_AGENTS):
		if p == from or not (p is Pawn):
			continue
		var other := p as Pawn
		for f in from.knowledge.all_facts():
			var fact := f as KnowledgeStore.Fact
			if fact.id.begins_with("Criminal"):
				other.knowledge.radio(fact.id, fact.last_pos, sim_time, fact.room_hint)


func apply_precog(kind: String, target_name: String) -> bool:
	var cost := _cost(kind)
	if cost > budget or mode != Mode.PRESENT:
		return false
	if running:
		running = false
		capture_snapshot()
	var pawn := _pawn(target_name)
	if pawn == null:
		return false
	budget -= cost
	budget_changed.emit(budget)
	match kind:
		"hostile_room_a":
			pawn.knowledge.precog("Criminal1", marker("room_a"), sim_time, "room_a")
			log_event("precog", "%s: hostile in Room A" % target_name, target_name)
		"hostile_room_b":
			pawn.knowledge.precog("Criminal2", marker("room_b"), sim_time, "room_b")
			log_event("precog", "%s: hostile in Room B" % target_name, target_name)
		"position":
			pawn.knowledge.precog("Criminal1", marker("room_a") + Vector3(1.4, 0, -1.2), sim_time, "room_a")
			log_event("precog", "%s: precise Criminal1 position" % target_name, target_name)
		"position_b":
			pawn.knowledge.precog("Criminal2", marker("room_b") + Vector3(0.4, 0, 0.6), sim_time, "room_b")
			log_event("precog", "%s: precise Criminal2 position" % target_name, target_name)
		"cautious":
			pawn.stance = Pawn.Stance.CAUTIOUS
			pawn.caution = 0.9
			log_event("precog", "%s: cautious" % target_name, target_name)
		"decisive":
			pawn.stance = Pawn.Stance.DECISIVE
			pawn.caution = 0.25
			log_event("precog", "%s: decisive" % target_name, target_name)
		"stealth":
			pawn.stance = Pawn.Stance.STEALTH
			log_event("precog", "%s: stealth" % target_name, target_name)
		"priority_civ":
			pawn.priority_civilian = true
			log_event("precog", "%s: civilian priority" % target_name, target_name)
	capture_snapshot()
	if has_node("Sfx"):
		get_node("Sfx").play_precog()
	return true


func _cost(kind: String) -> int:
	match kind:
		"position":
			return 2
		"position_b":
			return 2
		_:
			return 1


func log_event(kind: String, text: String, who: String) -> void:
	var entry := {"t": sim_time, "kind": kind, "text": text, "who": who}
	_timeline.append(entry)
	timeline_event.emit(entry)


func timeline() -> Array:
	return _timeline


func prev_timeline() -> Array:
	return _prev_timeline


func _replace_door_panels() -> void:
	if geometry.get_node_or_null("door_a_panel"):
		geometry.get_node("door_a_panel").free()
	if geometry.get_node_or_null("door_b_panel"):
		geometry.get_node("door_b_panel").free()
	var a := Door.new()
	a.name = "DoorA"
	actors.add_child(a)
	a.global_position = marker("door_a") + Vector3(0.0, 0.0, -0.85)
	a.opened.connect(func(): log_event("door", "Door A opened", ""))
	var b := Door.new()
	b.name = "DoorB"
	actors.add_child(b)
	b.global_position = marker("door_b") + Vector3(0.0, 0.0, -0.85)
	b.opened.connect(func(): log_event("door", "Door B opened", ""))


func _spawn_cast() -> void:
	_mk(Conventions.AGENT_A, Pawn.Faction.AGENT, marker("entrance") + Vector3(-0.7, 0, 0), 0.75, marker("room_a"), "reach_room_a")
	_mk(Conventions.AGENT_B, Pawn.Faction.AGENT, marker("entrance") + Vector3(0.7, 0, 0), 0.35, marker("room_a") + Vector3(1.2, 0, 0), "reach_room_a")
	var c1 := _mk(Conventions.CRIMINAL_1, Pawn.Faction.CRIMINAL, marker("room_a") + Vector3(1.5, 0, -1.4), 0.4, Vector3.INF, "patrol")
	c1.setup_patrol([
		marker("room_a") + Vector3(2.2, 0, -0.2),
		marker("room_a") + Vector3(-2.1, 0, -2.1),
		marker("room_a") + Vector3(-2.1, 0, 0.4),
		marker("room_a") + Vector3(1.4, 0, 1.2)
	], marker("door_a"))
	var c2 := _mk(Conventions.CRIMINAL_2, Pawn.Faction.CRIMINAL, marker("room_b") + Vector3(0.4, 0, 0.6), 0.4, Vector3.INF, "patrol")
	c2.setup_patrol([
		marker("room_b") + Vector3(-0.6, 0, -1.4),
		marker("room_b") + Vector3(1.4, 0, 0.2),
		marker("room_b") + Vector3(-0.4, 0, 1.6)
	], marker("door_b"))
	_mk(Conventions.CIVILIAN, Pawn.Faction.CIVILIAN, marker("room_a") + Vector3(-2.6, 0, -2.0), 0.8, marker("room_a") + Vector3(-2.6, 0, -2.0), "wait")
	var a_pawn := _pawn(Conventions.AGENT_A)
	if a_pawn:
		a_pawn.stance = Pawn.Stance.CAUTIOUS
	var b_pawn := _pawn(Conventions.AGENT_B)
	if b_pawn:
		b_pawn.stance = Pawn.Stance.DECISIVE


func _mk(n: String, fac: Pawn.Faction, pos: Vector3, caut: float, goal: Vector3, goal_text: String) -> Pawn:
	var p := Pawn.new()
	p.display_name = n
	p.faction = fac
	p.caution = caut
	p.name = n
	actors.add_child(p)
	p.global_position = pos + Vector3(0, 0.05, 0)
	p.set_goal(goal, goal_text)
	return p


func _pawn(n: String) -> Pawn:
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_PAWNS):
		if p is Pawn and (p as Pawn).display_name == n:
			return p
	return null


func _check_mission() -> void:
	if mode == Mode.PRESENT and not running:
		return
	if mode != Mode.EXECUTION and mode != Mode.PROJECTION and mode != Mode.PRESENT:
		return
	var civ := _pawn(Conventions.CIVILIAN)
	var a := _pawn(Conventions.AGENT_A)
	var b := _pawn(Conventions.AGENT_B)
	if civ and civ.downed:
		last_outcome = "FAIL civilian"
		if mode == Mode.EXECUTION:
			running = false
		return
	if a and b and a.downed and b.downed:
		last_outcome = "FAIL team down"
		if mode == Mode.EXECUTION:
			running = false
		return
	if _all_criminals_down() and civ and not civ.downed:
		last_outcome = "SUCCESS"
		if mode == Mode.EXECUTION:
			running = false


func _all_criminals_down() -> bool:
	var any := false
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_CRIMINALS):
		if not (p is Pawn):
			continue
		any = true
		if not (p as Pawn).downed:
			return false
	return any


func select_pawn_at_mouse() -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var mouse := get_viewport().get_mouse_position()
	var from := cam.project_ray_origin(mouse)
	var to := from + cam.project_ray_normal(mouse) * 80.0
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.collision_mask = Conventions.LAYER_CHARACTERS
	var hit := geometry.get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return
	var n: Node = hit.collider
	if n is Pawn:
		DebugMode.selected_pawn = n


func _tint(c: Color) -> void:
	if geometry == null:
		return
	var world := geometry.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world and world.environment:
		world.environment.ambient_light_color = Color(0.5, 0.52, 0.55) * c
		world.environment.background_color = Color(0.07, 0.08, 0.1) * c

