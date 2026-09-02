extends Node3D
## Headless proofs for movement and minds. Run:
## godot --headless --path . res://levels/tests/brain_harness.tscn

var geo: LevelGeometry
var host: SimHost
var passed: int = 0
var failed: int = 0
var _lines: PackedStringArray = []

func _ready() -> void:
	geo = LevelGeometry.new()
	add_child(geo)
	geo.build()
	host = SimHost.new()
	host.name = "Sim"
	add_child(host)
	host.setup(geo, false)
	geo.bake_for_play()
	_lines.append("nav polygons=%d" % geo.polygon_count())
	for i in 6:
		await get_tree().physics_frame
	if _want_visual():
		print("VISUAL MODE")
		DebugMode.enabled = true
		await _photo_hold_vs_flee()
		await get_tree().create_timer(6.0).timeout
		get_tree().quit(0)
		return
	await _case_a_agent_reaches_room()
	await _clear_pawns()
	await _case_a2_two_through_door()
	await _clear_pawns()
	await _case_a3_posted_still()
	await _clear_pawns()
	await _case_b_hostage_then_follow()
	await _clear_pawns()
	await _case_c_scared_criminal_exits()
	await _clear_pawns()
	await _case_d_holder_stays()
	await _clear_pawns()
	await _case_e_panic_kill()
	await _clear_pawns()
	await _case_f_group_lock()
	await _clear_pawns()
	var summary := "BRAIN HARNESS  %d passed  %d failed" % [passed, failed]
	print(summary)
	for line in _lines:
		print(line)
	if DisplayServer.get_name() == "headless":
		get_tree().quit(1 if failed > 0 else 0)
		return
	await _photo_hold_vs_flee()


func _clear_pawns() -> void:
	host.running = false
	for p in get_tree().get_nodes_in_group(Conventions.GROUP_PAWNS):
		p.queue_free()
	for d in get_tree().get_nodes_in_group(Conventions.GROUP_DOORS):
		if d is Door:
			(d as Door)._set_open_instant(false)
	await get_tree().process_frame
	await get_tree().process_frame


func _ok(name: String, cond: bool, detail: String) -> void:
	if cond:
		passed += 1
		_lines.append("PASS  %s  %s" % [name, detail])
	else:
		failed += 1
		_lines.append("FAIL  %s  %s" % [name, detail])


func _tick(seconds: float) -> void:
	host.running = true
	var t := 0.0
	while t < seconds:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	host.running = false


func _door_a() -> Door:
	for d in get_tree().get_nodes_in_group(Conventions.GROUP_DOORS):
		if d is Door and (d as Door).name == "DoorA":
			return d
	return null


func _in_wall(p: Pawn) -> bool:
	var space := geo.get_world_3d().direct_space_state
	var sphere := SphereShape3D.new()
	sphere.radius = 0.20
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = sphere
	q.transform = Transform3D(Basis(), p.global_position + Vector3(0, 0.95, 0))
	q.collision_mask = Conventions.LAYER_WORLD
	q.exclude = [p.get_rid()]
	for hit in space.intersect_shape(q, 8):
		var n: Node = hit.collider
		if n != null and str(n.name).begins_with("floor"):
			continue
		if n != null and str(n.name).begins_with("cover"):
			continue
		return true
	return false


func _watch(p: Pawn, dest: Vector3, seconds: float) -> Dictionary:
	var stuck := 0.0
	var last := p.global_position
	var wall := 0
	var jitter := 0
	var last_dir := Vector3.ZERO
	var door_open_t := -1.0
	var resume_t := -1.0
	var t := 0.0
	var door := _door_a()
	host.running = true
	while t < seconds:
		await get_tree().physics_frame
		var dt := get_physics_process_delta_time()
		t += dt
		var step_v := p.global_position - last
		step_v.y = 0.0
		var step := step_v.length()
		if dest.x != INF and p.global_position.distance_to(dest) > 1.15:
			if step < 0.012 and p.current_action not in ["open_door", "wait_door"]:
				stuck += dt
			else:
				stuck = 0.0
		if step > 0.04:
			var dir := step_v.normalized()
			if last_dir.length() > 0.5 and dir.dot(last_dir) < -0.55:
				if p.global_position.distance_to(host.marker("door_a")) < 1.8:
					jitter += 1
			last_dir = dir
		last = p.global_position
		if _in_wall(p):
			wall += 1
		if door and door.is_open and door_open_t < 0.0:
			door_open_t = t
		if door_open_t >= 0.0 and resume_t < 0.0 and step > 0.02 and p.current_action != "open_door":
			resume_t = t
		if dest.x != INF and p.global_position.distance_to(dest) <= 1.1:
			break
	host.running = false
	return {
		"t": t,
		"stuck": stuck,
		"wall": wall,
		"jitter": jitter,
		"door_open_t": door_open_t,
		"resume_t": resume_t,
		"dist": p.global_position.distance_to(dest) if dest.x != INF else 0.0,
		"opened": door != null and door.is_open,
		"doors_opened": p.doors_opened
	}


func _case_a_agent_reaches_room() -> void:
	var start := host.marker("entrance")
	var dest := host.marker("room_a")
	var agent := host.spawn_pawn("Walker", Pawn.Faction.AGENT, start, 0.4, dest, "clear_room_a")
	agent.role = Pawn.Role.SWEEPER
	agent.stance = Pawn.Stance.DECISIVE
	agent.combat_enabled = false
	await get_tree().physics_frame
	await get_tree().physics_frame
	var w := await _watch(agent, dest, 18.0)
	var resume_ok: bool = w.door_open_t >= 0.0 and w.resume_t >= 0.0 and w.resume_t - w.door_open_t < 0.65
	_ok("A_reach", w.dist <= 1.2, "dist=%.2f t=%.1f pos=%s %s" % [w.dist, w.t, agent.global_position, agent.debug_nav()])
	_ok("A_no_stuck", w.stuck < 2.2, "stuck=%.2fs action=%s" % [w.stuck, agent.current_action])
	_ok("A_door_opens", w.opened and w.doors_opened >= 1, "open=%s n=%d t=%.1f" % [w.opened, w.doors_opened, w.door_open_t])
	_ok("A_continues", resume_ok, "open=%.2f resume=%.2f" % [w.door_open_t, w.resume_t])
	_ok("A_no_wall", w.wall == 0, "wall_hits=%d" % w.wall)
	_ok("A_no_door_jitter", w.jitter <= 3, "reversals=%d" % w.jitter)


func _case_a2_two_through_door() -> void:
	var dest := host.marker("room_a")
	var a := host.spawn_pawn("Lead", Pawn.Faction.AGENT, host.marker("entrance") + Vector3(-0.55, 0, 0), 0.3, dest, "clear_room_a")
	var b := host.spawn_pawn("Trail", Pawn.Faction.AGENT, host.marker("entrance") + Vector3(0.55, 0, 0.4), 0.3, dest, "clear_room_a")
	a.role = Pawn.Role.SWEEPER
	b.role = Pawn.Role.SWEEPER
	a.combat_enabled = false
	b.combat_enabled = false
	a.stance = Pawn.Stance.DECISIVE
	b.stance = Pawn.Stance.DECISIVE
	await get_tree().physics_frame
	var min_sep := 99.0
	var wedge := 0.0
	var t := 0.0
	host.running = true
	while t < 20.0:
		await get_tree().physics_frame
		var dt := get_physics_process_delta_time()
		t += dt
		var sep := a.global_position.distance_to(b.global_position)
		min_sep = minf(min_sep, sep)
		if sep < 0.42:
			wedge += dt
		if a.global_position.distance_to(dest) <= 1.3 and b.global_position.distance_to(dest) <= 1.6:
			break
	host.running = false
	_ok("A2_both_arrive", a.global_position.distance_to(dest) <= 1.4 and b.global_position.distance_to(dest) <= 1.8, "a=%.2f b=%.2f t=%.1f" % [a.global_position.distance_to(dest), b.global_position.distance_to(dest), t])
	_ok("A2_no_wedge", wedge < 1.2 and min_sep > 0.35, "wedge=%.2fs min_sep=%.2f" % [wedge, min_sep])
	_ok("A2_door_open", _door_a() != null and _door_a().is_open, "open=%s" % (_door_a() != null and _door_a().is_open))


func _case_a3_posted_still() -> void:
	var post := host.marker("post_a")
	var cr := host.spawn_pawn("Posted", Pawn.Faction.CRIMINAL, post, 0.4, post, "hold_post")
	cr.role = Pawn.Role.POSTED
	cr.post_pos = post
	cr.combat_enabled = false
	await get_tree().physics_frame
	var origin := cr.global_position
	var drift := 0.0
	host.running = true
	host.emit_sound(post + Vector3(2, 0, 0), 12.0, "gunshot", "noise")
	var t := 0.0
	while t < 3.0:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		drift = maxf(drift, cr.global_position.distance_to(origin))
	host.running = false
	_ok("A3_posted_still", drift < 0.45 and cr.current_action != "flee", "drift=%.2f action=%s" % [drift, cr.current_action])


func _case_b_hostage_then_follow() -> void:
	var civ := host.spawn_pawn(Conventions.CIVILIAN, Pawn.Faction.CIVILIAN, host.marker("hostage"), 0.8, host.marker("hostage"), "held")
	civ.role = Pawn.Role.HOSTAGE
	var holder := host.spawn_pawn("Holder", Pawn.Faction.CRIMINAL, host.marker("holder"), 0.4, host.marker("holder"), "stay_on_hostage")
	holder.role = Pawn.Role.HOLDER
	holder.hold_name = Conventions.CIVILIAN
	holder.combat_enabled = false
	await get_tree().physics_frame
	var origin := civ.global_position
	host.running = true
	host.emit_sound(civ.global_position, 8.0, "gunshot", "test")
	await _tick(0.4)
	host.emit_sound(civ.global_position, 8.0, "gunshot", "test")
	await _tick(1.6)
	_ok("B_held_still", civ.global_position.distance_to(origin) < 0.35 and civ.current_action == "held", "moved=%.2f action=%s" % [civ.global_position.distance_to(origin), civ.current_action])
	holder.take_hit(200.0, holder)
	var agent := host.spawn_pawn("Escort", Pawn.Faction.AGENT, host.marker("room_b") + Vector3(-2.4, 0, 0), 0.3, host.marker("exit"), "extract")
	agent.role = Pawn.Role.SWEEPER
	agent.combat_enabled = false
	await get_tree().physics_frame
	var clip := 0.0
	var t := 0.0
	host.running = true
	var before := civ.global_position.distance_to(agent.global_position)
	while t < 4.0:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		if civ.global_position.distance_to(holder.global_position) < 0.48:
			clip += get_physics_process_delta_time()
	host.running = false
	var after := civ.global_position.distance_to(agent.global_position)
	var toward_exit := civ.global_position.distance_to(host.marker("exit")) < origin.distance_to(host.marker("exit")) - 0.4
	_ok("B_follows", civ.liberated and (after < before - 0.3 or toward_exit or civ.current_action == "follow"), "liberated=%s action=%s d0=%.2f d1=%.2f" % [civ.liberated, civ.current_action, before, after])
	_ok("B_no_clip", clip < 0.35, "clip=%.2fs" % clip)


func _case_c_scared_criminal_exits() -> void:
	var start := host.marker("room_a")
	var cr := host.spawn_pawn("Runner", Pawn.Faction.CRIMINAL, start, 0.3, start, "hold")
	cr.role = Pawn.Role.NONE
	cr.anxiety = 0.85
	cr.hold_name = ""
	cr.combat_enabled = false
	await get_tree().physics_frame
	var d0 := cr.global_position.distance_to(host.marker("exit"))
	var w := await _watch(cr, host.marker("exit"), 14.0)
	var d1 := cr.global_position.distance_to(host.marker("exit"))
	_ok("C_flees_exit", d1 < d0 - 1.5, "d0=%.2f d1=%.2f action=%s" % [d0, d1, cr.current_action])
	_ok("C_uses_doors", w.opened or cr.doors_opened >= 1 or d1 < 6.0, "opened=%s n=%d" % [w.opened, cr.doors_opened])
	_ok("C_no_wall", w.wall == 0, "wall_hits=%d" % w.wall)


func _case_d_holder_stays() -> void:
	var civ := host.spawn_pawn(Conventions.CIVILIAN, Pawn.Faction.CIVILIAN, host.marker("hostage"), 0.8, host.marker("hostage"), "held")
	civ.role = Pawn.Role.HOSTAGE
	var holder := host.spawn_pawn("Keeper", Pawn.Faction.CRIMINAL, host.marker("holder"), 0.35, host.marker("holder"), "stay_on_hostage")
	holder.role = Pawn.Role.HOLDER
	holder.hold_name = Conventions.CIVILIAN
	holder.combat_enabled = false
	await get_tree().physics_frame
	host.running = true
	host.emit_sound(holder.global_position + Vector3(2, 0, 0), 16.0, "gunshot", "noise")
	await _tick(0.4)
	host.emit_sound(holder.global_position + Vector3(2, 0, 0), 16.0, "gunshot", "noise")
	await _tick(1.6)
	var dist := holder.global_position.distance_to(civ.global_position)
	_ok("D_holder_stays", dist <= 1.8 and holder.current_action != "flee", "dist=%.2f action=%s anxiety=%.2f" % [dist, holder.current_action, holder.anxiety])


func _case_e_panic_kill() -> void:
	var civ := host.spawn_pawn(Conventions.CIVILIAN, Pawn.Faction.CIVILIAN, host.marker("hostage"), 0.8, host.marker("hostage"), "held")
	civ.role = Pawn.Role.HOSTAGE
	var holder := host.spawn_pawn("Keeper", Pawn.Faction.CRIMINAL, host.marker("holder"), 0.35, host.marker("holder"), "stay_on_hostage")
	holder.role = Pawn.Role.HOLDER
	holder.hold_name = Conventions.CIVILIAN
	holder.combat_enabled = false
	holder.look_at(Vector3(civ.global_position.x, holder.global_position.y, civ.global_position.z), Vector3.UP)
	await get_tree().physics_frame
	host.running = true
	for i in 3:
		host.emit_sound(civ.global_position, 10.0, "gunshot", "panic%d" % i)
		await _tick(0.25)
	await _tick(1.2)
	host.running = false
	_ok("E_panic_seen", civ.downed and civ.gunshots_heard >= 3, "downed=%s shots=%d action=%s" % [civ.downed, civ.gunshots_heard, civ.current_action])


func _case_f_group_lock() -> void:
	var civ := host.spawn_pawn(Conventions.CIVILIAN, Pawn.Faction.CIVILIAN, host.marker("hostage"), 0.8, host.marker("hostage"), "held")
	civ.role = Pawn.Role.HOSTAGE
	var holder := host.spawn_pawn("Keeper", Pawn.Faction.CRIMINAL, host.marker("holder"), 0.35, host.marker("holder"), "stay_on_hostage")
	holder.role = Pawn.Role.HOLDER
	holder.hold_name = Conventions.CIVILIAN
	holder.combat_enabled = false
	var posted := host.spawn_pawn("Posted", Pawn.Faction.CRIMINAL, host.marker("post_a"), 0.4, host.marker("post_a"), "hold_post")
	posted.role = Pawn.Role.POSTED
	posted.post_pos = host.marker("post_a")
	posted.combat_enabled = false
	await get_tree().physics_frame
	var p0 := posted.global_position
	var h0 := holder.global_position
	host.running = true
	host.emit_sound(host.marker("central"), 20.0, "gunshot", "raid")
	await _tick(2.0)
	host.running = false
	_ok("F_posted_holds", posted.current_action != "flee" and posted.global_position.distance_to(p0) < 0.55, "action=%s drift=%.2f anx=%.2f" % [posted.current_action, posted.global_position.distance_to(p0), posted.anxiety])
	_ok("F_holder_holds", holder.current_action != "flee" and holder.global_position.distance_to(h0) < 0.55, "action=%s drift=%.2f" % [holder.current_action, holder.global_position.distance_to(h0)])


func _want_visual() -> bool:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	return args.has("visual") or args.has("--visual")


func _shot_dir() -> String:
	var d := "/opt/cursor/artifacts/screenshots"
	DirAccess.make_dir_recursive_absolute(d)
	return d


func _save_shot(name: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var tex := get_viewport().get_texture()
	if tex == null:
		return
	var img := tex.get_image()
	if img == null:
		return
	img.save_png("%s/%s.png" % [_shot_dir(), name])
	print("SHOT %s" % name)


func _photo_hold_vs_flee() -> void:
	await _clear_pawns()
	var cam := ObserverCamera.new()
	cam.name = "Observer"
	cam.pivot = Vector3(-1.0, 0.0, 12.0)
	cam.distance = 16.0
	cam.yaw = -0.35
	cam.pitch = -0.75
	add_child(cam)
	cam.set_view(Vector3(-0.2, 0.0, 10.0), 15.0, -0.2, -0.72)
	await get_tree().create_timer(2.5).timeout
	var walker := host.spawn_pawn("Walker", Pawn.Faction.AGENT, host.marker("entrance"), 0.3, host.marker("room_a"), "clear_room_a")
	walker.role = Pawn.Role.SWEEPER
	walker.stance = Pawn.Stance.DECISIVE
	walker.combat_enabled = false
	host.running = true
	await _tick(2.0)
	await _save_shot("verified_corridor_walk")
	var t := 0.0
	while t < 9.0 and not (_door_a() != null and _door_a().is_open):
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	cam.set_view(Vector3(-4.0, 0.0, 18.0), 11.5, -1.05, -0.62)
	await _tick(0.55)
	await _save_shot("verified_door_open")
	while t < 12.0 and walker.global_position.distance_to(host.marker("room_a")) > 1.4:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	cam.set_view(Vector3(-7.2, 0.0, 18.0), 11.0, -1.2, -0.6)
	await _tick(0.35)
	await _save_shot("verified_room_a_arrive")
	host.running = false
	await _clear_pawns()
	cam.set_view(Vector3(-2.0, 0.0, 20.0), 16.0, -0.95, -0.7)
	var runner := host.spawn_pawn("Runner", Pawn.Faction.CRIMINAL, host.marker("room_a"), 0.3, host.marker("exit"), "flee_exit")
	runner.role = Pawn.Role.NONE
	runner.anxiety = 0.9
	runner.combat_enabled = false
	host.running = true
	await _tick(3.4)
	await _save_shot("verified_flee_exit")
	host.running = false
	await _clear_pawns()
	cam.set_view(Vector3(12.4, 0.0, 18.4), 10.0, -0.9, -0.55)
	var civ := host.spawn_pawn(Conventions.CIVILIAN, Pawn.Faction.CIVILIAN, host.marker("hostage"), 0.8, host.marker("hostage"), "held")
	civ.role = Pawn.Role.HOSTAGE
	var holder := host.spawn_pawn("Keeper", Pawn.Faction.CRIMINAL, host.marker("holder"), 0.35, host.marker("holder"), "stay_on_hostage")
	holder.role = Pawn.Role.HOLDER
	holder.hold_name = Conventions.CIVILIAN
	holder.combat_enabled = false
	host.emit_sound(holder.global_position, 6.0, "gunshot", "noise")
	host.running = true
	await _tick(2.2)
	await _save_shot("verified_hold_hostage")
	host.running = false
