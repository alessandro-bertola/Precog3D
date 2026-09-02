class_name KnowledgeStore
extends RefCounted
## Per-character facts. Never contains world truth automatically.

class Fact:
	var id: String = ""
	var last_pos: Vector3 = Vector3.ZERO
	var last_time: float = 0.0
	var source: String = "none"
	var seen_now: bool = false
	var room_hint: String = ""

var _facts: Dictionary = {}

func see(id: String, pos: Vector3, time: float, room: String = "") -> void:
	var f: Fact = _facts.get(id, Fact.new())
	f.id = id
	f.last_pos = pos
	f.last_time = time
	f.source = "seen"
	f.seen_now = true
	f.room_hint = room
	_facts[id] = f


func hear(id: String, pos: Vector3, time: float) -> void:
	var f: Fact = _facts.get(id, Fact.new())
	f.id = id
	if not f.seen_now:
		f.last_pos = pos
		f.source = "heard"
		f.last_time = time
	_facts[id] = f


func radio(id: String, pos: Vector3, time: float, room: String = "") -> void:
	var f: Fact = _facts.get(id, Fact.new())
	f.id = id
	f.last_pos = pos
	f.last_time = time
	f.source = "radio"
	f.room_hint = room
	f.seen_now = false
	_facts[id] = f


func precog(id: String, pos: Vector3, time: float, room: String) -> void:
	var f: Fact = _facts.get(id, Fact.new())
	f.id = id
	f.last_pos = pos
	f.last_time = time
	f.source = "precog"
	f.room_hint = room
	f.seen_now = false
	_facts[id] = f


func mark_lost(id: String) -> void:
	if _facts.has(id):
		(_facts[id] as Fact).seen_now = false


func get_fact(id: String) -> Fact:
	return _facts.get(id, null)


func all_facts() -> Array:
	return _facts.values()


func knows_hostile_in(room: String) -> bool:
	for f in _facts.values():
		var fact := f as Fact
		if fact.room_hint == room and fact.id.begins_with("Criminal"):
			return true
	return false


func last_pos_in(room: String) -> Vector3:
	for f in _facts.values():
		var fact := f as Fact
		if fact.room_hint == room and fact.id.begins_with("Criminal"):
			return fact.last_pos
	return Vector3.INF


func debug_lines() -> String:
	if _facts.is_empty():
		return "knows: nothing"
	var lines: PackedStringArray = []
	for f in _facts.values():
		var fact := f as Fact
		var age := "now" if fact.seen_now else "stale"
		lines.append("%s [%s %s] %s" % [fact.id, fact.source, age, fact.room_hint])
	return "\n".join(lines)
