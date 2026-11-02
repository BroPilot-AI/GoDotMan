extends Area3D

var time: float = 0.0
var base_y: float
const BOB_SPEED := 2.0
const BOB_AMPLITUDE := 0.3
const SPIN_SPEED := 2.0


func _ready() -> void:
	base_y = position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	time += delta
	position.y = base_y + sin(time * BOB_SPEED) * BOB_AMPLITUDE
	rotation.y += SPIN_SPEED * delta


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		GameManager.add_bolt()
		var tween := create_tween()
		tween.tween_property(self, "scale", Vector3(1.5, 1.5, 1.5), 0.1)
		tween.parallel().tween_property(self, "global_position:y", global_position.y + 1.0, 0.15)
		tween.tween_callback(queue_free)
