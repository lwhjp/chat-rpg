extends KinematicBody2D

const MAX_SPEED = 150
const ACCELERATION = 800
const DECELERATION = 2000

var velocity = Vector2.ZERO
var direction = Vector2.RIGHT

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

func _physics_process(delta):
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if input_vector.is_equal_approx(Vector2.ZERO):
		velocity = velocity.move_toward(Vector2.ZERO, delta * DECELERATION)
	else:
		velocity = (velocity + input_vector.normalized() * ACCELERATION * delta).clamped(MAX_SPEED)
		direction = input_vector

	animation_tree.set("parameters/Idle/blend_position", direction);
	animation_tree.set("parameters/Walk/blend_position", direction);
	velocity = move_and_slide(velocity)
	animation_state.travel("Idle" if velocity.is_equal_approx(Vector2.ZERO) else "Walk")
