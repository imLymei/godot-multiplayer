extends Control


var rotation_step = 2
var min_rotation_step = 0.1


@onready var direction = [-1, 1].pick_random()


func _physics_process(delta: float) -> void:
	if rotation_step > min_rotation_step: rotation_step -= 0.1
	rotation_degrees += rotation_step * direction
