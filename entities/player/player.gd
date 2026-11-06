extends CharacterBody3D
class_name Player

func _physics_process(_delta: float) -> void:
	# Executes the velocity changes applied by the MovementController
	move_and_slide()
