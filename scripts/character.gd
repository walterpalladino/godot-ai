extends CharacterBody3D

const RAY_LENGTH = 1000
const LEFT_MOUSE_BUTTON = 1

#
#const SPEED = 5.0
#const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


#func _physics_process(delta):
	# Add the gravity.
#	if not is_on_floor():
#		velocity.y -= gravity * delta

	# Handle Jump.
#	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
#		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
#	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
#	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
#	if direction:
#		velocity.x = direction.x * SPEED
#		velocity.z = direction.z * SPEED
#	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED)
#		velocity.z = move_toward(velocity.z, 0, SPEED)

#	move_and_slide()

@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree : AnimationTree = get_node("Model/male_80/AnimationTree")
#@export var animation_tree : AnimationTree 
@onready var camera = get_parent_node_3d().get_node("Camera3D")


var Speed = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if(navigation_agent.is_navigation_finished()):
		velocity = Vector3.ZERO
	else:
		move_to_point(delta, Speed)

	update_animations()
		

func move_to_point(delta, speed):
	
	var target_pos = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(target_pos)
	
	face_direction(target_pos)
	
	var new_velocity = direction * speed
	velocity = velocity.move_toward(new_velocity, 0.25)
	
	move_and_slide()
	

func face_direction(direction):
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)
#	rotation.y = lerp_angle(rotation.y, global_position.y, 0.25)
	#look_at(Vector3(lerp(direction.x, global_position.x, 0.5), global_position.y, lerp(direction.z, global_position.z, 0.5)), Vector3.UP)


func _input(event):

	if event is InputEventMouseButton && event.is_pressed() && event.button_index == LEFT_MOUSE_BUTTON: 

		var position = get_world_position()		
		if position:
			navigation_agent.target_position = position
		
		
		
func get_world_position():
	
	var mouse_position = get_viewport().get_mouse_position()
	
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * RAY_LENGTH
	var space = get_world_3d().direct_space_state
	
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = true
		
	var result = space.intersect_ray(ray_query)
	
	#print(result)
	#print(result.collider.name)
	
	if result:
		return result.position
	else:
		return null

# Update animations
func update_animations():

	var is_idle : bool = velocity.x == 0.0 && velocity.z == 0.0
	var is_walking : bool = velocity.x != 0.0 || velocity.z != 0.0
	
	#print(velocity)
	#print(is_on_floor())
	#print(is_idle)
	#print(is_walking)
	
	animation_tree.set("parameters/conditions/idle", is_idle)
	animation_tree.set("parameters/conditions/walking", is_walking)
	#$AnimationTree.set("parameters/conditions/straifLeft", input_dir.x == -1 && is_on_floor())
	#$AnimationTree.set("parameters/conditions/straifRight", input_dir.x == 1 && is_on_floor())
	#$AnimationTree.set("parameters/conditions/falling", !is_on_floor())
	#$AnimationTree.set("parameters/conditions/landed", is_on_floor())
