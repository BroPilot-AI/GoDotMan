extends Control

@onready var btn_gobot: Button = $VBoxContainer/HBoxContainer/VBoxGobot/BtnGobot
@onready var btn_gdbot: Button = $VBoxContainer/HBoxContainer/VBoxGDBot/BtnGDBot
@onready var btn_sophia: Button = $VBoxContainer/HBoxContainer/VBoxSophia/BtnSophia

@onready var tex_gobot: TextureRect = $VBoxContainer/HBoxContainer/VBoxGobot/TexRect
@onready var tex_gdbot: TextureRect = $VBoxContainer/HBoxContainer/VBoxGDBot/TexRect
@onready var tex_sophia: TextureRect = $VBoxContainer/HBoxContainer/VBoxSophia/TexRect

@onready var btn_start: Button = $VBoxContainer/StartButton
@onready var btn_quit: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	btn_gobot.pressed.connect(_on_select_gobot)
	btn_gdbot.pressed.connect(_on_select_gdbot)
	btn_sophia.pressed.connect(_on_select_sophia)
	btn_start.pressed.connect(_on_start)
	btn_quit.pressed.connect(_on_quit)

	_update_ui()


func _on_select_gobot() -> void:
	GameManager.selected_character = "gobot"
	_update_ui()

func _on_select_gdbot() -> void:
	GameManager.selected_character = "gdbot"
	_update_ui()

func _on_select_sophia() -> void:
	GameManager.selected_character = "sophia"
	_update_ui()


func _update_ui() -> void:
	var c = GameManager.selected_character
	
	# Dim unselected characters out logically
	tex_gobot.modulate = Color(1, 1, 1, 1.0) if c == "gobot" else Color(0.3, 0.3, 0.3, 0.7)
	tex_gdbot.modulate = Color(1, 1, 1, 1.0) if c == "gdbot" else Color(0.3, 0.3, 0.3, 0.7)
	tex_sophia.modulate = Color(1, 1, 1, 1.0) if c == "sophia" else Color(0.3, 0.3, 0.3, 0.7)
	
	btn_gobot.text = "★ Gobot" if c == "gobot" else "Gobot"
	btn_gdbot.text = "★ GDBot" if c == "gdbot" else "GDBot"
	btn_sophia.text = "★ Sophia" if c == "sophia" else "Sophia"


func _on_start() -> void:
	GameManager.current_level = 1
	GameManager.score = 0
	get_tree().change_scene_to_file("res://scenes/world_1.tscn")

func _on_quit() -> void:
	get_tree().quit()
