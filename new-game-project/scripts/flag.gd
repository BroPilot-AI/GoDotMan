extends Area3D

var triggered := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if triggered:
		return
	if body.is_in_group("player"):
		triggered = true

		if body.has_method("_update_animations"):
			body.set_physics_process(false)
		var player_skin: Node3D = body.get_node_or_null("GobotSkin")
		if player_skin and player_skin.has_method("victory_sign"):
			player_skin.victory_sign()

		var label := Label.new()
		label.text = "LEVEL COMPLETE!"
		label.add_theme_font_size_override("font_size", 48)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.anchors_preset = Control.PRESET_CENTER
		label.add_theme_color_override("font_color", Color.GOLD)

		var canvas := CanvasLayer.new()
		canvas.add_child(label)
		get_tree().root.add_child(canvas)

		GameManager.complete_level()
