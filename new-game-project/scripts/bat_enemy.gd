extends Area3D

const DIVE_SPEED := 20.0
const DETECTION_RADIUS := 12.0

var player: Node3D
var is_diving := false
var original_pos: Vector3
var target_pos: Vector3
var is_stomped := false
var cooldown := 0.0

@onready var skin = $RoundBatSkin

func _ready() -> void:
	add_to_group("enemy")
	original_pos = global_position
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float) -> void:
	if is_stomped: return

	if cooldown > 0.0:
		cooldown -= delta
		global_position = global_position.move_toward(original_pos, DIVE_SPEED * 0.4 * delta)
		if global_position.distance_to(original_pos) > 0.1:
			var d = (original_pos - global_position).normalized()
			skin.rotation.y = lerp_angle(skin.rotation.y, atan2(d.x, d.z), 10.0 * delta)
		return

	if is_diving:
		var dist = global_position.distance_to(target_pos)
		global_position = global_position.move_toward(target_pos, DIVE_SPEED * delta)
		if dist < 0.5:
			is_diving = false
			cooldown = 1.5
			_fire_projectile()
	else:
		var dist_to_player = 999.0
		if is_instance_valid(player):
			dist_to_player = global_position.distance_to(player.global_position)
			var p_dir = (player.global_position - global_position).normalized()
			skin.rotation.y = lerp_angle(skin.rotation.y, atan2(p_dir.x, p_dir.z), 5.0 * delta)
			
		if dist_to_player < DETECTION_RADIUS:
			is_diving = true
			if is_instance_valid(player):
				target_pos = player.global_position

func _fire_projectile() -> void:
	var proj = preload("res://scenes/enemy_projectile.tscn").instantiate()
	get_tree().root.add_child(proj)
	proj.global_position = global_position
	if is_instance_valid(player):
		proj.direction = (player.global_position - global_position).normalized()
	else:
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
