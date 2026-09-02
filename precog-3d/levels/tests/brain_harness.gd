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
	await _case_a_agent_reaches_room()
	await _clear_pawns()
	await _case_b_hostage_then_follow()
	await _clear_pawns()
	await _case_c_scared_criminal_exits()
	await _clear_pawns()
	await _case_d_holder_stays()
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


func _case_a_agent_reaches_room() -> void:
	var start := host.marker("entrance")
	var dest := host.marker("room_a")
	var agent := host.spawn_pawn("Walker", Pawn.Faction.AGENT, start, 0.4, dest, "clear_room_a")
	agent.role = Pawn.Role.SWEEPER
	agent.stance = Pawn.Stance.DECISIVE
	await get_tree().physics_frame
	await get_tree().physics_frame
	var map := geo.get_navigation_map()
	_lines.append("A closest start=%s dest=%s" % [
		str(NavigationServer3D.map_get_closest_point(map, start)),
		str(NavigationServer3D.map_get_closest_point(map, dest))
	])
	var stuck := 0.0
	var last := agent.global_position
	host.running = true
	var t := 0.0
	var dumped := false
	while t < 18.0:
		await get_tree().physics_frame
		var dt := get_physics_process_delta_time()
		t += dt
		var step := agent.global_position.distance_to(last)
		last = agent.global_position
		var far := agent.global_position.distance_to(dest) > 1.1
		if far and step < 0.01 and agent.current_action != "open_door":
			stuck += dt
		else:
			stuck = 0.0
		if not dumped and t > 0.8:
			dumped = true
			_lines.append("A nav %s vel=%s" % [agent.debug_nav(), str(agent.velocity)])
		if agent.global_position.distance_to(dest) <= 1.1:
			break
	host.running = false
	_ok("A_reach", agent.global_position.distance_to(dest) <= 1.2, "dist=%.2f t=%.1f" % [agent.global_position.distance_to(dest), t])
	_ok("A_no_stuck", stuck < 2.2, "stuck=%.2fs action=%s" % [stuck, agent.current_action])


func _case_b_hostage_then_follow() -> void:
	var civ := host.spawn_pawn(Conventions.CIVILIAN, Pawn.Faction.CIVILIAN, host.marker("hostage"), 0.8, host.marker("hostage"), "held")
	civ.role = Pawn.Role.HOSTAGE
	var holder := host.spawn_pawn("Holder", Pawn.Faction.CRIMINAL, host.marker("holder"), 0.4, host.marker("holder"), "stay_on_hostage")
	holder.role = Pawn.Role.HOLDER
	holder.hold_name = Conventions.CIVILIAN
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
	await get_tree().physics_frame
	var before := civ.global_position.distance_to(agent.global_position)
	await _tick(4.0)
	var after := civ.global_position.distance_to(agent.global_position)
	var toward_exit := civ.global_position.distance_to(host.marker("exit")) < origin.distance_to(host.marker("exit")) - 0.4
	_ok("B_follows", civ.liberated and (after < before - 0.3 or toward_exit or civ.current_action == "follow"), "liberated=%s action=%s d0=%.2f d1=%.2f" % [civ.liberated, civ.current_action, before, after])


func _case_c_scared_criminal_exits() -> void:
	var start := host.marker("room_a")
	var cr := host.spawn_pawn("Runner", Pawn.Faction.CRIMINAL, start, 0.3, start, "hold")
	cr.role = Pawn.Role.NONE
	cr.anxiety = 0.85
	cr.hold_name = ""
	await get_tree().physics_frame
	var d0 := cr.global_position.distance_to(host.marker("exit"))
	await _tick(6.0)
	var d1 := cr.global_position.distance_to(host.marker("exit"))
	_ok("C_flees_exit", d1 < d0 - 1.5, "d0=%.2f d1=%.2f action=%s" % [d0, d1, cr.current_action])


func _case_d_holder_stays() -> void:
	var civ := host.spawn_pawn(Conventions.CIVILIAN, Pawn.Faction.CIVILIAN, host.marker("hostage"), 0.8, host.marker("hostage"), "held")
	civ.role = Pawn.Role.HOSTAGE
	var holder := host.spawn_pawn("Keeper", Pawn.Faction.CRIMINAL, host.marker("holder"), 0.35, host.marker("holder"), "stay_on_hostage")
	holder.role = Pawn.Role.HOLDER
	holder.hold_name = Conventions.CIVILIAN
	await get_tree().physics_frame
	host.running = true
	host.emit_sound(holder.global_position + Vector3(2, 0, 0), 16.0, "gunshot", "noise")
	await _tick(0.4)
	host.emit_sound(holder.global_position + Vector3(2, 0, 0), 16.0, "gunshot", "noise")
	await _tick(1.6)
	var dist := holder.global_position.distance_to(civ.global_position)
	_ok("D_holder_stays", dist <= 1.8 and holder.current_action != "flee", "dist=%.2f action=%s anxiety=%.2f" % [dist, holder.current_action, holder.anxiety])


func _photo_hold_vs_flee() -> void:
	await _clear_pawns()
	var cam := ObserverCamera.new()
	cam.name = "Observer"
	add_child(cam)
	var civ := host.spawn_pawn(Conventions.CIVILIAN, Pawn.Faction.CIVILIAN, host.marker("hostage"), 0.8, host.marker("hostage"), "held")
	civ.role = Pawn.Role.HOSTAGE
	var holder := host.spawn_pawn("Keeper", Pawn.Faction.CRIMINAL, host.marker("holder"), 0.35, host.marker("holder"), "stay_on_hostage")
	holder.role = Pawn.Role.HOLDER
	holder.hold_name = Conventions.CIVILIAN
	var runner := host.spawn_pawn("Runner", Pawn.Faction.CRIMINAL, host.marker("room_a"), 0.3, host.marker("exit"), "flee_exit")
	runner.role = Pawn.Role.NONE
	runner.anxiety = 0.9
	host.emit_sound(holder.global_position, 6.0, "gunshot", "noise")
	host.running = true
