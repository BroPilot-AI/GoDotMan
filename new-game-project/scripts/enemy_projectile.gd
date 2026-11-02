extends Area3D

const SPEED := 10.0
const LIFETIME := 2.0

var direction := Vector3.FORWARD
var timer: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta
	timer += delta
	rotation.x += 10.0 * delta
	if timer >= LIFETIME:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage()
		queue_free()
	elif body.is_in_group("enemy"):
		return
	else:
		queue_free()
