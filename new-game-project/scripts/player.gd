extends CharacterBody3D

const SPEED := 10.0
const JUMP_VELOCITY := 13.0
const STOMP_BOUNCE := 8.0
const ROTATION_SPEED := 12.0
const GRAVITY := 32.0
const FALL_GRAVITY := 45.0
const GROUND_POUND_SPEED := 35.0
const COYOTE_TIME := 0.12
const JUMP_BUFFER_TIME := 0.1

# Power-up durations
const BOLT_SHOT_DURATION := 15.0
const STAR_DURATION := 8.0
const BOLT_COOLDOWN := 0.3

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var can_double_jump: bool = true
var is_dead: bool = false
var spawn_position: Vector3
var invincible: bool = false
var invincible_timer: float = 0.0
var last_direction := Vector3.BACK

# Power-up state
var has_bolt_shot: bool = false
var bolt_shot_timer: float = 0.0
var bolt_cooldown_timer: float = 0.0
var star_power: bool = false
var star_timer: float = 0.0
var is_ground_pounding: bool = false

var has_laser_sword: bool = false
var sword_timer: float = 0.0
var sword_cooldown: float = 0.0

var has_hover_boots: bool = false
var hover_timer: float = 0.0

var bolt_particles: GPUParticles3D
var star_particles: GPUParticles3D

var bolt_projectile_scene: PackedScene = preload("res://scenes/bolt_projectile.tscn")

var _gdbot_scene = preload("res://addons/gdquest_gdbot/gdbot_skin.tscn")
var _sophia_scene = preload("res://addons/gdquest_sophia/sophia_skin.tscn")
var _gobot_scene = preload("res://addons/gdquest_gobot/gobot_skin.tscn")

@onready var skin_container: Node3D = $Skin
var skin: Node3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	spawn_position = global_position
	add_to_group("player")
	_setup_skin()
	_setup_powerup_particles()

func _setup_skin() -> void:
	var char_name = GameManager.selected_character
	var inst = null
	if char_name == "GDBot":
		inst = _gdbot_scene.instantiate()
	elif char_name == "Sophia":
		inst = _sophia_scene.instantiate()
	else:
		inst = _gobot_scene.instantiate()
	skin_container.add_child(inst)
	skin = inst

func _setup_powerup_particles() -> void:
	bolt_particles = GPUParticles3D.new()
	var bolt_mat = StandardMaterial3D.new()
	bolt_mat.albedo_color = Color(1.0, 0.5, 0.0)
	bolt_mat.emission_enabled = true
	bolt_mat.emission = Color(1.0, 0.5, 0.0)
	var bolt_mesh = QuadMesh.new()
	bolt_mesh.size = Vector2(0.15, 0.15)
	bolt_mesh.material = bolt_mat
	bolt_particles.draw_pass_1 = bolt_mesh
	bolt_particles.emitting = false
	var bolt_process = ParticleProcessMaterial.new()
	bolt_process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	bolt_process.emission_sphere_radius = 0.5
	bolt_process.direction = Vector3(0, 1, 0)
	bolt_process.gravity = Vector3(0, 2, 0)
	bolt_particles.process_material = bolt_process
	bolt_particles.amount = 16
	bolt_particles.lifetime = 1.0
	add_child(bolt_particles)

	star_particles = GPUParticles3D.new()
	var star_mat = StandardMaterial3D.new()
	star_mat.albedo_color = Color(1.0, 1.0, 0.0)
	star_mat.emission_enabled = true
	star_mat.emission = Color(1.0, 1.0, 0.0)
	var star_mesh = QuadMesh.new()
	star_mesh.size = Vector2(0.2, 0.2)
	star_mesh.material = star_mat
	star_particles.draw_pass_1 = star_mesh
	star_particles.emitting = false
	var star_process = ParticleProcessMaterial.new()
	star_process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	star_process.emission_sphere_radius = 0.6
	star_process.direction = Vector3(0, 1, 0)
	star_process.gravity = Vector3(0, 0, 0)
	star_process.radial_accel_min = 1.0
	star_process.radial_accel_max = 2.0
	star_particles.process_material = star_process
	star_particles.amount = 30
	star_particles.lifetime = 0.8
	add_child(star_particles)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_handle_invincibility(delta)
	_handle_powerup_timers(delta)
	_apply_gravity(delta)
	_handle_jump(delta)
	_handle_ground_pound(delta)
	_handle_movement(delta)
	_handle_attack()

	move_and_slide()
	_check_enemy_collisions()
	_check_fell_off()
	_update_animations()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		if is_ground_pounding:
			velocity.y = -GROUND_POUND_SPEED
		elif has_hover_boots and Input.is_action_pressed("jump") and velocity.y <= 0.0:
			velocity.y = -0.05
		else:
			var grav := FALL_GRAVITY if velocity.y < 0.0 else GRAVITY
			velocity.y -= grav * delta
		coyote_timer -= delta
	else:
		if is_ground_pounding:
			is_ground_pounding = false
			_ground_pound_land()
		coyote_timer = COYOTE_TIME


func _handle_jump(delta: float) -> void:
	jump_buffer_timer -= delta

	if is_on_floor():
		can_double_jump = true

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	if jump_buffer_timer > 0.0:
		if is_on_floor() or coyote_timer > 0.0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0.0
			coyote_timer = 0.0
			is_ground_pounding = false
		elif can_double_jump and not is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0.0
			can_double_jump = false
			is_ground_pounding = false
			skin.jump()

	# Variable jump height
	if Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y *= 0.5


func _handle_ground_pound(_delta: float) -> void:
	if not is_on_floor() and not is_ground_pounding:
		if Input.is_action_just_pressed("ground_pound"):
			is_ground_pounding = true
			jump_buffer_timer = 0.0
			velocity.x = 0.0
			velocity.z = 0.0
			velocity.y = 0.0


func _ground_pound_land() -> void:
	# Kill nearby enemies on landing
	var nearby := get_tree().get_nodes_in_group("enemy")
	for enemy in nearby:
		if enemy is Node3D and enemy.has_method("stomped"):
			var dist := global_position.distance_to(enemy.global_position)
			if dist < 3.0:
				enemy.stomped()
				GameManager.add_score(200)

	# Small bounce after ground pound
	velocity.y = 4.0

	# Visual feedback - shake the skin
	var tween := create_tween()
	tween.tween_property(skin, "scale", Vector3(1.3, 0.7, 1.3), 0.08)
	tween.tween_property(skin, "scale", Vector3.ONE, 0.15)


func _handle_movement(delta: float) -> void:
	if is_ground_pounding:
		return

	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_forward", "move_back")

	var var_dir := Vector3(input_dir.x, 0.0, input_dir.y).normalized()
	
	var cam = get_viewport().get_camera_3d()
	var direction := Vector3.ZERO
	if cam and var_dir.length() > 0.1:
		var cam_basis = cam.global_transform.basis
		direction = (cam_basis * var_dir)
		direction.y = 0
		direction = direction.normalized()
	else:
		direction = var_dir

	if direction.length() > 0.1:
		var current_speed := SPEED * (1.5 if star_power else 1.0)
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		last_direction = direction

		var target_angle := atan2(direction.x, direction.z)
		skin.rotation.y = lerp_angle(skin.rotation.y, target_angle, ROTATION_SPEED * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, SPEED * 8.0 * delta)


func _handle_attack() -> void:
	if sword_cooldown > 0.0:
		sword_cooldown -= get_process_delta_time()
	if Input.is_action_just_pressed("attack"):
		if has_laser_sword and sword_cooldown <= 0.0:
			_swing_sword()
		elif has_bolt_shot and bolt_cooldown_timer <= 0.0:
			_fire_bolt()


func _swing_sword() -> void:
	sword_cooldown = 0.5
	if skin.has_method("flip"):
		skin.flip()
	var arc = preload("res://scenes/sword_arc.tscn").instantiate()
	get_tree().root.add_child(arc)
	arc.global_position = global_position + Vector3.UP * 1.0 + last_direction * 1.5
	arc.look_at(arc.global_position + last_direction)

func _fire_bolt() -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return
	bolt_cooldown_timer = BOLT_COOLDOWN
	var bolt: Area3D = bolt_projectile_scene.instantiate()
	get_tree().root.add_child(bolt)
	bolt.global_position = global_position + Vector3.UP * 0.8 + last_direction * 0.5
	bolt.direction = last_direction.normalized()

	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = load("res://assets/audio/shoot.wav")
	audio_player.volume_db = -10.0
	get_tree().root.add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)

	# Flip animation
	if skin.has_method("flip"):
		skin.flip()


func activate_laser_sword() -> void:
	has_laser_sword = true
	sword_timer = 20.0

func activate_hover_boots() -> void:
	has_hover_boots = true
	hover_timer = 20.0

func _handle_powerup_timers(delta: float) -> void:
	if has_laser_sword:
		sword_timer -= delta
		if sword_timer <= 0.0:
			has_laser_sword = false
	if has_hover_boots:
		hover_timer -= delta
		if hover_timer <= 0.0:
			has_hover_boots = false
			
	if has_bolt_shot:
		bolt_shot_timer -= delta
		bolt_cooldown_timer -= delta
		if bolt_shot_timer <= 0.0:
			has_bolt_shot = false
			bolt_particles.emitting = false

	if star_power:
		star_timer -= delta
		# Rainbow flash effect during star power
		var hue := fmod(star_timer * 3.0, 1.0)
		var star_color := Color.from_hsv(hue, 0.7, 1.0)
		skin.visible = true
		_set_skin_modulate(star_color)
		if star_timer <= 0.0:
			star_power = false
			invincible = false
			_set_skin_modulate(Color.WHITE)
			star_particles.emitting = false


func _set_skin_modulate(color: Color) -> void:
	# Apply color tint via the mesh instances in the skin
	for child in skin.get_children():
		if child is MeshInstance3D:
			var mat: Material = child.get_active_material(0)
			if mat is StandardMaterial3D:
				mat.albedo_color = color


func _check_enemy_collisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()

		if collider is CharacterBody3D and collider.is_in_group("enemy") and collider.has_method("stomped"):
			if star_power:
				# Star power kills on contact
				collider.stomped()
				GameManager.add_score(200)
			elif global_position.y > collider.global_position.y + 0.5 and velocity.y < 0.0:
				# Stomp from above
				collider.stomped()
				velocity.y = STOMP_BOUNCE
				GameManager.add_score(200)
			elif not invincible:
				take_damage()


func _check_fell_off() -> void:
	if global_position.y < -10.0:
		die()


func _update_animations() -> void:
	if is_ground_pounding:
		if skin.has_method("fall"):
			skin.fall()
		return

	if is_on_floor():
		var speed := Vector2(velocity.x, velocity.z).length()
		if speed > 0.5:
			if skin.has_method("run"):
				skin.run()
			elif skin.has_method("walk"):
				skin.walk()
			elif skin.has_method("move"):
				skin.move()
		else:
			if skin.has_method("idle"):
				skin.idle()
	else:
		if velocity.y > 0.0:
			if skin.has_method("jump"):
				skin.jump()
		else:
			if skin.has_method("fall"):
				skin.fall()


func take_damage() -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return
	if invincible or is_dead or star_power:
		return

	# Lose power-up first before losing a life
	if has_bolt_shot:
		has_bolt_shot = false
		bolt_shot_timer = 0.0
		bolt_particles.emitting = false
		_start_invincibility()
		skin.hurt()
		return

	skin.hurt()
	GameManager.lose_life()
	if GameManager.lives > 0:
		_start_invincibility()
		global_position = spawn_position
		velocity = Vector3.ZERO
	else:
		die()


func die() -> void:
	is_dead = true
	velocity = Vector3.ZERO
	set_collision_layer_value(2, false)

	var tween := create_tween()
	tween.tween_property(skin, "scale", Vector3(0.01, 0.01, 0.01), 0.6)
	tween.tween_callback(_on_death_complete)


func _on_death_complete() -> void:
	skin.scale = Vector3.ONE
	set_collision_layer_value(2, true)

	if GameManager.lives > 0:
		is_dead = false
		global_position = spawn_position
		velocity = Vector3.ZERO
		_start_invincibility()
	else:
		GameManager.game_over()


func _start_invincibility() -> void:
	invincible = true
	invincible_timer = 1.5


func _handle_invincibility(delta: float) -> void:
	if star_power:
		return
	if not invincible:
		return
	invincible_timer -= delta
	skin.visible = fmod(invincible_timer, 0.2) > 0.1
	if invincible_timer <= 0.0:
		invincible = false
		skin.visible = true


# ==================== POWER-UP ACTIVATION ====================

func activate_bolt_shot() -> void:
	has_bolt_shot = true
	bolt_shot_timer = BOLT_SHOT_DURATION
	bolt_cooldown_timer = 0.0
	bolt_particles.emitting = true

	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = load("res://assets/audio/powerup_active.wav")
	get_tree().root.add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)

	# Orange glow feedback
	var tween := create_tween()
	tween.tween_property(skin, "scale", Vector3(1.2, 1.2, 1.2), 0.15)
	tween.tween_property(skin, "scale", Vector3.ONE, 0.15)


func activate_star_power() -> void:
	star_power = true
	star_timer = STAR_DURATION
	invincible = true
	invincible_timer = STAR_DURATION
	star_particles.emitting = true

	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = load("res://assets/audio/powerup_active.wav")
	get_tree().root.add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)

	# Speed boost is handled in _handle_movement
