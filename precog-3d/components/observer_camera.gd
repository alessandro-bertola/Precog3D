class_name ObserverCamera
extends Node3D
## Free observation camera. Never issues orders to characters.

@export var pivot: Vector3 = Vector3(1.0, 0.0, 16.0)
@export var distance: float = 18.0
@export var yaw: float = -0.7
@export var pitch: float = -0.85
@export var min_distance: float = 7.0
@export var max_distance: float = 32.0

var _cam: Camera3D
var _dragging := false
var _panning := false
var _home_pivot: Vector3
var _home_distance: float
var _home_yaw: float
var _home_pitch: float

func _ready() -> void:
	_home_pivot = pivot
	_home_distance = distance
	_home_yaw = yaw
	_home_pitch = pitch
	_cam = Camera3D.new()
	_cam.name = "Camera3D"
	_cam.current = true
	_cam.fov = 50.0
	add_child(_cam)
	_apply()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = mb.pressed
			get_viewport().set_input_as_handled()
		elif mb.button_index == MOUSE_BUTTON_MIDDLE:
			_panning = mb.pressed
			get_viewport().set_input_as_handled()
		elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = clampf(distance - 1.2, min_distance, max_distance)
			_apply()
			get_viewport().set_input_as_handled()
		elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = clampf(distance + 1.2, min_distance, max_distance)
			_apply()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if _dragging:
			yaw -= mm.relative.x * 0.006
			pitch = clampf(pitch - mm.relative.y * 0.006, -1.35, -0.25)
			_apply()
			get_viewport().set_input_as_handled()
		elif _panning:
			var right := Vector3(cos(yaw), 0.0, -sin(yaw))
			var fwd := Vector3(sin(yaw), 0.0, cos(yaw))
			pivot += (-right * mm.relative.x + fwd * mm.relative.y) * 0.03
			_apply()
			get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R or event.keycode == KEY_HOME:
			reset_view()
			get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	var pan := Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		pan.z -= 1.0
	if Input.is_key_pressed(KEY_S):
		pan.z += 1.0
	if Input.is_key_pressed(KEY_A):
		pan.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		pan.x += 1.0
	if pan != Vector3.ZERO:
		var right := Vector3(cos(yaw), 0.0, -sin(yaw))
		var fwd := Vector3(sin(yaw), 0.0, cos(yaw))
		pivot += (right * pan.x + fwd * pan.z).normalized() * 8.0 * delta
		_apply()
	if Input.is_key_pressed(KEY_Q):
		yaw -= 0.9 * delta
		_apply()
	if Input.is_key_pressed(KEY_E):
		yaw += 0.9 * delta
		_apply()


func reset_view() -> void:
	pivot = _home_pivot
	distance = _home_distance
	yaw = _home_yaw
	pitch = _home_pitch
	_apply()


func _apply() -> void:
	var offset := Vector3(
		sin(yaw) * cos(pitch),
		-sin(pitch),
		cos(yaw) * cos(pitch)
	) * distance
	_cam.position = pivot + offset
	var look := pivot + Vector3(0, 1.2, 0)
	if _cam.position.distance_squared_to(look) > 0.0001:
		_cam.look_at_from_position(_cam.position, look, Vector3.UP)
