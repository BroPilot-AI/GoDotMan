extends CharacterBody3D

const SPEED := 2.0
const GRAVITY := 20.0

var direction := Vector3.LEFT
var is_stomped := false

@onready var skin: Node3D = $BeetleBotSkin
@onready var ray_front: RayCast3D = $RayFront
@onready var ray_ground: RayCast3D = $RayGround


func _ready() -> void:
	add_to_group("enemy")
	skin.idle()
	# Randomize initial direction along X axis
	if randf() > 0.5:
		direction = Vector3.RIGHT
	_update_ray_directions()


func _physics_process(delta: float) -> void:
	if is_stomped:
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	move_and_slide()

	# Turn around at walls
	if is_on_wall():
		direction = -direction
		_update_ray_directions()

	# Turn around at ledges
	if is_on_floor() and not ray_ground.is_colliding():
		direction = -direction
		_update_ray_directions()

	# Face movement direction
	var target_angle := atan2(direction.x, direction.z)
	skin.rotation.y = lerp_angle(skin.rotation.y, target_angle, 8.0 * delta)
	skin.walk()


func _update_ray_directions() -> void:
	ray_front.position = Vector3(direction.x * 0.5, 0.5, direction.z * 0.5)
	ray_front.target_position = direction * 0.5
	ray_ground.position = Vector3(direction.x * 0.6, 0.2, direction.z * 0.6)
	ray_ground.target_position = Vector3(0, -0.5, 0)


func stomped() -> void:
	if is_stomped:
		return
	is_stomped = true
	velocity = Vector3.ZERO

	skin.power_off()
	var tween := create_tween()
	tween.tween_property(skin, "scale", Vector3(1.2, 0.1, 1.2), 0.3)
	tween.tween_property(skin, "scale", Vector3(0.01, 0.01, 0.01), 0.3)
	tween.tween_callback(queue_free)
