extends Area3D

enum PowerUpType { BOLT_SHOT, STAR, EXTRA_LIFE, LASER_SWORD, HOVER_BOOTS }

@export var type: PowerUpType = PowerUpType.BOLT_SHOT

func _ready() -> void:
	body_entered.connect(_on_body_entered)



func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	match type:
		PowerUpType.BOLT_SHOT:
			if body.has_method("activate_bolt_shot"):
				body.activate_bolt_shot()
		PowerUpType.STAR:
			if body.has_method("activate_star_power"):
				body.activate_star_power()
		PowerUpType.EXTRA_LIFE:
			GameManager.lives += 1
		PowerUpType.LASER_SWORD:
			if body.has_method("activate_laser_sword"):
				body.activate_laser_sword()
		PowerUpType.HOVER_BOOTS:
			if body.has_method("activate_hover_boots"):
				body.activate_hover_boots()

	GameManager.add_score(500)

	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = load("res://assets/audio/pickup.wav")
	audio_player.volume_db = -5.0
	get_tree().root.add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)

	# Collect animation
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3(1.5, 1.5, 1.5), 0.1)
	tween.parallel().tween_property(self, "global_position:y", global_position.y + 1.5, 0.2)
	tween.tween_callback(queue_free)
