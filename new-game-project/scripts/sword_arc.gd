extends Area3D

var timer := 0.0

func _ready() -> void:
	# Scale up rapidly for a fast sweeping strike aesthetic
	scale = Vector3(0.01, 0.01, 0.01)
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
	
	var sfx = AudioStreamPlayer.new()
	sfx.stream = preload("res://assets/audio/shoot.wav")
	sfx.pitch_scale = 0.5 # Deep swoosh sound instead of high pop
	add_child(sfx)
	sfx.play()

func _physics_process(delta: float) -> void:
	timer += delta
	if timer > 0.3:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy") and body.has_method("stomped"):
		body.stomped()
		GameManager.add_score(500)

func _on_area_entered(area: Area3D) -> void:
	if area.name.contains("EnemyProjectile"):
		area.queue_free() # Vaporize projectiles!
	elif area.is_in_group("enemy") and area.has_method("stomped"):
		area.stomped()
		GameManager.add_score(500)
