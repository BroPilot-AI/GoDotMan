extends Node3D
## Orbit Camera that follows the player, classic 3D platformer style.

@export var target: NodePath
@export var zoom := 9.0
@export var height := 2.0
@export var mouse_sensitivity := 0.2
@export var joystick_sensitivity := 3.0

var _target_node: Node3D
var yaw := PI / 2.0 # Start facing +X
var pitch := -0.2

func _ready() -> void:
	_target_node = get_node_or_null(target)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if _target_node:
		var offset_dir = Vector3.BACK.rotated(Vector3.RIGHT, pitch).rotated(Vector3.UP, yaw)
		global_position = _target_node.global_position + Vector3.UP * height + offset_dir * zoom
		look_at(_target_node.global_position + Vector3.UP * height)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity * 0.01
		pitch -= event.relative.y * mouse_sensitivity * 0.01

func _physics_process(delta: float) -> void:
	if not _target_node:
		return
		
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
	var joy_x = Input.get_axis("camera_left", "camera_right")
	var joy_y = Input.get_axis("camera_up", "camera_down")
	yaw -= joy_x * joystick_sensitivity * delta
	pitch -= joy_y * joystick_sensitivity * delta
	
	pitch = clamp(pitch, -1.2, 0.4)
	
	var offset_dir = Vector3.BACK.rotated(Vector3.RIGHT, pitch).rotated(Vector3.UP, yaw)
	var desired_pos = _target_node.global_position + Vector3.UP * height + offset_dir * zoom
	
	global_position = global_position.lerp(desired_pos, 8.0 * delta)
	look_at(_target_node.global_position + Vector3.UP * height)
