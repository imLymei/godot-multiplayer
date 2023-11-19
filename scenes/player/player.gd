extends CharacterBody2D


const SPEED := 200.0
const ACCEL := 1200.0

const JUMP_VELOCITY := -300.0
const MIN_JUMP := JUMP_VELOCITY / 2
const GRAVITY := 9.4

const SYNC_LERP = 0.4

var sync_position = Vector2.ZERO

@onready var fairy_spot: Node2D = $FairySpot
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $'../MultiplayerSynchronizer'
@onready var id_label: Label = $IdLabel


func _ready() -> void:
	var id = str(owner.name)
	multiplayer_synchronizer.set_multiplayer_authority(int(id))
	id_label.text = id


func _physics_process(delta: float) -> void:
	if multiplayer_synchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		global_position = global_position.lerp(sync_position, SYNC_LERP)
		return
	
	if not is_on_floor():
		velocity.y += GRAVITY
	
	if Input.is_action_just_pressed('jump') and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released('jump') and velocity.y <= MIN_JUMP:
		velocity.y = MIN_JUMP
	
	var direction := Input.get_axis('move_left', 'move_right')
	velocity.x = move_toward(velocity.x, direction * SPEED, ACCEL * delta)
	
	if direction > 0:
		fairy_spot.position.x = abs(fairy_spot.position.x) * -1
	if direction < 0:
		fairy_spot.position.x = abs(fairy_spot.position.x)
	
	if Input.is_action_just_pressed('click'):
		create_boom_text.rpc(get_global_mouse_position())
	
	move_and_slide()
	
	sync_position = global_position

@rpc("any_peer", "call_local")
func create_boom_text(mouse_position):
	var bang_text = preload('res://scenes/bang_text/bang_text.tscn').instantiate()
	bang_text.global_position = mouse_position
	get_tree().root.add_child(bang_text)
