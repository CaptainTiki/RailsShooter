extends Node3D

@export var input_target : InputTarget

var move_speed : float = 4
var move_progress : float = 0.0
var max_rotation : float = 0.3
var rotation_speed : float = 2

var roll_tween : Tween 

func _process(delta: float) -> void:
	move_progress += delta * move_speed
	position = position.move_toward(input_target.position,delta * move_speed)
	
	if Input.is_action_just_pressed("dodge_roll"):
		dodge_roll()
	
	if input_target.position.x < position.x : #moving left
		rotation.z = move_toward(rotation.z, max_rotation,rotation_speed * delta)
	elif input_target.position.x > position.x : #moving right
		rotation.z = move_toward(rotation.z, -max_rotation,rotation_speed )
	else:
		rotation.z = move_toward(rotation.z ,0 ,rotation_speed * delta)
	
	if input_target.position.y < position.y : #moving down
		rotation.x = move_toward(rotation.x, -max_rotation,rotation_speed * delta)
	elif input_target.position.y > position.y : #moving up
		rotation.x = move_toward(rotation.x, max_rotation,rotation_speed * delta)
	else:
		rotation.x = move_toward(rotation.x, 0, rotation_speed * delta)

func dodge_roll() -> void:
	#TODO: set invul flags here
	var rotate_target = rotation.z + (2 * PI)
	roll_tween = create_tween()
	roll_tween.tween_property(self, "rotation:z", rotate_target, 0.5)
	roll_tween.connect("finished", finish_roll)
	roll_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func finish_roll() -> void:
	#TODO: unset invul flags here
	#TODO: set roll cooldown
	rotation.z = 0
