extends Area3D

const SPEED := 6.0
const TRAVEL_DIST := 8.0

var original_pos: Vector3
var target_pos: Vector3
var moving_right := true
var is_stomped := false
var shoot_timer := 0.0

@onready var skin = $BeeBotSkin

func _ready() -> void:
	add_to_group("enemy")
	original_pos = global_position
	target_pos = original_pos + Vector3.RIGHT * TRAVEL_DIST

func _physics_process(delta: float) -> void:
	if is_stomped: return

	global_position = global_position.move_toward(target_pos, SPEED * delta)
	
	if global_position.distance_to(target_pos) < 0.1:
		moving_right = !moving_right
		target_pos = original_pos + (Vector3.RIGHT * TRAVEL_DIST if moving_right else Vector3.LEFT * TRAVEL_DIST)
		skin.rotation.y = PI / 2.0 if moving_right else -PI / 2.0

	shoot_timer -= delta
	if shoot_timer <= 0.0:
		shoot_timer = 2.5
		_fire_projectile()

func _fire_projectile() -> void:
	var proj = preload("res://scenes/enemy_projectile.tscn").instantiate()
	get_tree().root.add_child(proj)
	proj.global_position = global_position + Vector3.DOWN * 0.5
	proj.direction = Vector3.DOWN

func stomped() -> void:
	if is_stomped: return
	is_stomped = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 0.3)
	tween.tween_callback(queue_free)

func _on_body_entered(body: Node3D) -> void:
	if is_stomped: return
	if body.is_in_group("player") and body.has_method("take_damage"):
		if body.velocity.y < 0.0 and body.global_position.y > global_position.y:
			stomped()
			body.velocity.y = 8.0 # Stomp bounce
			body.is_ground_pounding = false
			body.can_double_jump = true
			GameManager.add_score(200)
		else:
			if not body.star_power:
				body.take_damage()
			else:
				stomped()
