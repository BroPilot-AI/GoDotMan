extends Area3D

const SPEED := 15.0
const LIFETIME := 2.0

var direction := Vector3.FORWARD
var timer: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta
	timer += delta
	# Spin while flying
	rotation.x += 10.0 * delta
	if timer >= LIFETIME:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy") and body.has_method("stomped"):
		body.stomped()
		GameManager.add_score(200)
		queue_free()
	elif body.is_in_group("player"):
		# Don't collide with the player who shot it
		return
	else:
		# Hit a wall or the ground
		_spawn_hit_effect()
		queue_free()


func _spawn_hit_effect() -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return
	var particles := GPUParticles3D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.lifetime = 0.3
	particles.amount = 8
	get_tree().root.add_child(particles)
	particles.global_position = global_position
	# Auto-free after particles finish
	get_tree().create_timer(0.5).timeout.connect(particles.queue_free)
