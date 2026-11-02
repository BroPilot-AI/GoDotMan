extends CanvasLayer

@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel
@onready var bolt_label: Label = $MarginContainer/HBoxContainer/BoltLabel
@onready var lives_label: Label = $MarginContainer/HBoxContainer/LivesLabel
@onready var powerup_label: Label = $MarginContainer/HBoxContainer/PowerUpLabel

var player: CharacterBody3D


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.bolts_changed.connect(_on_bolts_changed)
	_update_all()


func _process(_delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
		return

	if player.star_power:
		powerup_label.text = "STAR!"
		powerup_label.add_theme_color_override("font_color", Color.YELLOW)
	elif player.has_bolt_shot:
		var secs := int(player.bolt_shot_timer)
		powerup_label.text = "BOLT [%ds]" % secs
		powerup_label.add_theme_color_override("font_color", Color.ORANGE)
	else:
		powerup_label.text = ""


func _update_all() -> void:
	_on_score_changed(GameManager.score)
	_on_lives_changed(GameManager.lives)
	_on_bolts_changed(GameManager.bolts)


func _on_score_changed(new_score: int) -> void:
	score_label.text = "SCORE: %d" % new_score


func _on_lives_changed(new_lives: int) -> void:
	lives_label.text = "LIVES: %d" % new_lives


func _on_bolts_changed(new_bolts: int) -> void:
	bolt_label.text = "BOLTS: %d" % new_bolts
