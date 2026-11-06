extends Node

@export var speed_walk = 5.0
@export var speed_sprint = 8.0
@export var speed_crouch = 3.0
@export var acceleration = 60.0
@export var jump_velocity = 4.5
@export var air_control = 20.0

@onready var player: CharacterBody3D = get_parent()
@onready var standing_collision: CollisionShape3D = $"../standing_collision_shape"
@onready var crouching_collision: CollisionShape3D = $"../crouching_collision_shape"
@onready var above_head: RayCast3D = $"../above_head"

var speed_current = 5.0
var direction = Vector3.ZERO

func _physics_process(delta: float) -> void:
	# 1. Crouch State & Collisions
	if Input.is_action_pressed("crouch"):
		speed_current = speed_crouch
		standing_collision.set_deferred("disabled", true)
		crouching_collision.set_deferred("disabled", false)
	elif not above_head.is_colliding():
		standing_collision.set_deferred("disabled", false)
		crouching_collision.set_deferred("disabled", true)
		
		if player.is_on_floor():
			if Input.is_action_pressed("sprint"):
				speed_current = speed_sprint
			else:
				speed_current = speed_walk

	# 2. Gravity & Jumping
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta

	if Input.is_action_just_pressed("jump") and player.is_on_floor() and not above_head.is_colliding():
		player.velocity.y = jump_velocity

	# 3. Input & Velocity Calculation
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var target_velocity = direction * speed_current
	var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	
	if player.is_on_floor():
		horizontal_velocity = horizontal_velocity.move_toward(target_velocity, acceleration * delta)
	elif direction != Vector3.ZERO:
		horizontal_velocity = horizontal_velocity.move_toward(target_velocity, air_control * delta)
			
	# 4. Apply to Parent
	player.velocity.x = horizontal_velocity.x
	player.velocity.z = horizontal_velocity.z
