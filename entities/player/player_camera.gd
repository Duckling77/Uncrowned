extends Node3D

@export var mouse_sens = 0.07
@export var lerp_speed = 10.0
@export var crouching_depth = -0.5

@onready var player: CharacterBody3D = get_parent()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotate the parent body horizontally
		player.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		# Rotate this head node vertically
		rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Handle head height for crouching
	if Input.is_action_pressed("crouch"):
		position.y = lerp(position.y, 1.8 + crouching_depth, delta * lerp_speed)
	else:
		position.y = lerp(position.y, 1.8, delta * lerp_speed)
