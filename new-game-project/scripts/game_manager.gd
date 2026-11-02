extends Node

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal bolts_changed(new_bolts: int)

var selected_character: String = "Gobot"
var current_level: int = 1

var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)

var lives: int = 3:
	set(value):
		lives = value
		lives_changed.emit(lives)

var bolts: int = 0:
	set(value):
		bolts = value
		bolts_changed.emit(bolts)


func reset() -> void:
	score = 0
	lives = 3
	bolts = 0


func add_score(amount: int) -> void:
	score += amount


func add_bolt() -> void:
	bolts += 1
	add_score(100)


func lose_life() -> void:
	lives -= 1
	if lives <= 0:
		game_over()


func game_over() -> void:
	reset()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")


func complete_level() -> void:
	add_score(1000)
	await get_tree().create_timer(2.0).timeout
	current_level += 1
	var next_level_path = "res://scenes/world_" + str(current_level) + ".tscn"
	if ResourceLoader.exists(next_level_path):
		get_tree().call_deferred("change_scene_to_file", next_level_path)
	else:
		reset()
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")
