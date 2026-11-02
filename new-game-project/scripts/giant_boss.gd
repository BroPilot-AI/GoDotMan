extends CharacterBody3D

@export var max_hp := 10
var hp := 10
var state := 0
var timer := 0.0
var original_color: Color

@onready var mesh = $MeshInstance3D
@onready var mat = StandardMaterial3D.new()

func _ready() -> void:
	mat.albedo_color = Color(0.8, 0.1, 0.2, 1)
	original_color = mat.albedo_color
	mesh.set_surface_override_material(0, mat)
	add_to_group("enemy")
	hp = max_hp

func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player or not is_inside_tree() or hp <= 0: return
	
	timer += delta
	if state == 0:
		var dir = (player.global_position - global_position)
		dir.y = 0
		if dir.length() > 0:
			velocity = dir.normalized() * 5.0
		
		# Jump logic occasionally
		if is_on_floor() and randf() < 0.02:
			velocity.y = 15.0
		
		if not is_on_floor():
			velocity.y -= 30.0 * delta
			
		move_and_slide()
		
		if randf() < 0.01:
			state = 1
	elif state == 1:
		# Stop and Fire Bullet hell
		velocity = Vector3.ZERO
		if not is_on_floor():
			velocity.y -= 30.0 * delta
		move_and_slide()

		if randf() < 0.15:
			# Bullet hell
			var bolt = preload("res://scenes/enemy_projectile.tscn").instantiate()
			# add safely
			get_parent().add_child(bolt)
			bolt.global_position = global_position + Vector3.UP * 4.0
			bolt.direction = (player.global_position + Vector3(randf()-0.5, randf(), randf()-0.5)*5.0 - bolt.global_position).normalized()
			
		if randf() < 0.02:
			state = 0

func stomped() -> void:
	if hp <= 0: return
	hp -= 1
	
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector3(0.5, 0.5, 0.5), 0.1)
	tw.tween_property(self, "scale", Vector3.ONE, 0.1)
	
	mat.albedo_color = Color.WHITE
	get_tree().create_timer(0.2).timeout.connect(_reset_color)
	
	if hp <= 0:
		GameManager.add_score(10000)
		# Victory effect
		var p = GPUParticles3D.new()
		p.emitting = true
		p.amount = 200
		p.lifetime = 1.0
		p.one_shot = true
		p.visibility_aabb = AABB(Vector3(-10, -10, -10), Vector3(20, 20, 20))
		get_parent().add_child(p)
		p.global_position = global_position
		get_tree().create_timer(1.5).timeout.connect(p.queue_free)
		
		GameManager.call_deferred("complete_level")
		queue_free()

func _reset_color() -> void:
	if is_inside_tree() and mat:
		mat.albedo_color = original_color
