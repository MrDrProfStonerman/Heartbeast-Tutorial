extends CharacterBody2D

@export var movement_data : PlayerMovementData

var double_jump = false
var just_wall_jumped = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_wall_normal = Vector2.ZERO
var is_sprinting = false

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var start_position = global_position
@onready var wall_jump_timer = $WallJumpTimer



func _physics_process(delta):
	apply_gravity(delta)
	wall_jump()
	jump()
	sprint()
	var input_axis = Input.get_axis("moveleft", "moveright")
	accelerate(input_axis, delta)
	air_accel(input_axis, delta)
	friction(input_axis, delta)
	air_resistance(input_axis, delta)
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	if was_on_wall:
		was_wall_normal = get_wall_normal()
	move_and_slide()
	var just_left_ledge = was_on_floor && !is_on_floor() && velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	just_wall_jumped = false
	var just_left_wall = was_on_wall
	if just_left_wall:
		wall_jump_timer.start()
	print(velocity)
func apply_gravity(delta):
	if !is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta
		
func wall_jump():
	if !is_on_wall_only() && wall_jump_timer.time_left <= 0.0:
		return
	var wall_normal = get_wall_normal()
	if wall_jump_timer.time_left > 0.0:
		wall_normal = was_wall_normal
	if Input.is_action_just_pressed("jump"):
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_force
		just_wall_jumped = true
		double_jump = true
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h

func jump():
	if is_on_floor():
		double_jump = true
	if is_on_floor() || coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_force
	elif !is_on_floor():
		if Input.is_action_just_released("jump") && velocity.y < movement_data.jump_force / 2:
			velocity.y = movement_data.jump_force / 2
		if Input.is_action_just_pressed("jump") && double_jump && !just_wall_jumped:
			velocity.y = movement_data.jump_force
			double_jump = false
func sprint():
	if Input.is_action_pressed("sprint"):
		is_sprinting = true
	else:
		is_sprinting = false
func friction(input_axis, delta):
	if input_axis == 0 && is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
func air_resistance(input_axis, delta):
	if input_axis == 0 && !is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)
func accelerate(input_axis, delta):
	if !is_on_floor():
		return
	if input_axis != 0 && !is_sprinting:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.accel * delta)
	if is_sprinting:
		velocity.x = move_toward(velocity.x, movement_data.sprint * input_axis, movement_data.accel * delta)
func air_accel(input_axis, delta):
	if is_on_floor():
		return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_accel * delta)
func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	if !is_on_floor():
		animated_sprite_2d.play("jump")


func _on_hazard_detect_area_entered(area):
	global_position = start_position

