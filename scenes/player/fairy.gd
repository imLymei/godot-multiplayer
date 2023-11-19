extends Node2D


const ACCEL = 0.05

var off_set = randf_range(-10, 10)

var wing_direction := 1
var wing_step := 25
var wing_rotation := 0
var wing_range := {'max': 55, 'min': -10}

@onready var fairy_spot: Node2D = $'../Player/FairySpot'
@onready var timer: Timer = $Timer
@onready var left_wing: Node2D = $FairyBodySprite/LeftWing
@onready var right_wing: Node2D = $FairyBodySprite/RightWing


func _physics_process(delta: float) -> void:
	if timer.is_stopped():
		timer.start()
		off_set = randf_range(-10, 10)
	
	if wing_direction == 1:
		if wing_rotation < wing_range.get('max'):
			wing_rotation += wing_step
		else:
			wing_direction = -1
			wing_rotation -= wing_step
	else:
		if wing_rotation > wing_range.get('min'):
			wing_rotation -= wing_step
		else:
			wing_direction = 1
			wing_rotation += wing_step
	
	left_wing.rotation_degrees = wing_rotation
	right_wing.rotation_degrees = -wing_rotation
	
	
	global_position = global_position.lerp(fairy_spot.global_position + Vector2(off_set, off_set), ACCEL)
