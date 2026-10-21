extends CharacterBody3D

# Player Nodes
@onready var head: Node3D = $head
@onready var standing_collision_shape: CollisionShape3D = $standing_collision_shape
@onready var crouching_collision_shape: CollisionShape3D = $crouching_collision_shape
@onready var above_head: RayCast3D = $above_head

# Speed Vars
var speed_current = 5.0
var acceleration = 60.0
var speed_walk = 5.0
var speed_sprint = 8.0
var speed_crouch = 3.0

# Movement Vars
var jump_velocity = 4.5
var air_control = 100.0
var air_resistance = 0.0
var crouching_depth = -0.5
var lerp_speed = 10.0

# Input Vars
var direction = Vector3.ZERO
@export var mouse_sens = 0.07




func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# Mouse looking logic
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	
	# Handle movement state
	
	if Input.is_action_pressed("crouch"):
		# Crouching
		speed_current = speed_crouch
		head.position.y = lerp(head.position.y, 1.8 + crouching_depth, delta*lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
	elif !above_head.is_colliding():
		# Standing
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		head.position.y = lerp(head.position.y, 1.8, delta*lerp_speed)
		
		if Input.is_action_pressed("sprint") and is_on_floor():
			# Sprinting
			speed_current = speed_sprint
		else:
			# Walking
			speed_current = speed_walk
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and !above_head.is_colliding():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	
	var target_velocity = direction * speed_current
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	if is_on_floor():
		# Ground Movement
		horizontal_velocity = horizontal_velocity.move_toward(target_velocity, acceleration * delta)
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
	else:
		# Air Movement
		if direction:
			horizontal_velocity = horizontal_velocity.move_toward(target_velocity, air_control * delta)
		
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, air_resistance * delta)
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
	
	#if direction:
		#velocity.x = direction.x * speed_current
		#velocity.z = direction.z * speed_current
	#else:
		#velocity.x = move_toward(velocity.x, 0, speed_current)
		#velocity.z = move_toward(velocity.z, 0, speed_current)

	move_and_slide()
