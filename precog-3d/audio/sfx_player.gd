extends Node
## Tiny procedural cues. Not a full mix.

func play_gunshot() -> void:
	_blip(180.0, 0.08, -8.0)


func play_precog() -> void:
	_blip(420.0, 0.12, -12.0)


func _blip(freq: float, dur: float, db: float) -> void:
	var player := AudioStreamPlayer.new()
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = 22050
	player.stream = gen
	player.volume_db = db
	add_child(player)
	player.play()
	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback:
		var frames := int(dur * gen.mix_rate)
		for i in frames:
			var t := float(i) / gen.mix_rate
			var s := sin(t * TAU * freq) * (1.0 - t / dur)
			playback.push_frame(Vector2(s, s))
	await get_tree().create_timer(dur + 0.05).timeout
	player.queue_free()
