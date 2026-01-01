extends StaticBody3D

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
#	Check the character structure: Geometry/model
#	where model represents the 3d model including animationplayer and animationtree
@onready var animation_tree : AnimationTree = get_node("Geometry/model/AnimationTree")
#@export var animation_tree : AnimationTree 
@onready var camera = get_parent_node_3d().get_node("Camera3D")


@export var walking_speed : float = 3.0
@export var running_speed : float = 6.0


#
@onready var default_3d_map_rid: RID = get_world_3d().get_navigation_map()

var movement_delta: float
var path_point_margin: float = 0.5

var current_path_index: int = 0
var current_path_point: Vector3
var current_path: PackedVector3Array

#
var velocity : Vector3 = Vector3.ZERO



# Called when the node enters the scene tree for the first time.
func _ready():
	#motion_mode = MOTION_MODE_GROUNDED

	#print_debug("_ready")
	#print_debug(get_tree().current_scene.name)
	#print_debug( get_tree().get_root().get_node(get_tree().current_scene.name + "Camera3D") )

	#pass # Replace with function body.
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

	# Wait for NavigationServer sync to adapt to made changes.
	#await get_tree().physics_frame

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
	move_to_point(delta, walking_speed)

	update_animations()
		

func move_to_point(delta, movement_speed):

	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		velocity = Vector3.ZERO
		navigation_agent.target_position = global_position
		return
		
	if navigation_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		navigation_agent.target_position = global_position
		return
		
	if !navigation_agent.is_target_reachable():
		velocity = Vector3.ZERO
		navigation_agent.target_position = global_position
		return


	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	####var direction = global_position.direction_to(target_pos)
	
	face_to(next_path_position)
	
	#var new_velocity = direction * speed
	#velocity = velocity.move_toward(new_velocity, delta * 2.5)
	
#	move(delta)
	movement_delta = movement_speed * delta
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_delta
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

	
	
func face_to(target_pos):

	#	Hard Turn
	#look_at(Vector3(target_pos.x, global_position.y, target_pos.z), Vector3.UP)
	#	Soft Turn
	var new_direction: Vector3 = self.global_position.direction_to(Vector3(target_pos.x, global_position.y, target_pos.z))
	var target: Basis = Basis.looking_at(new_direction)
	basis = basis.slerp(target, 0.1)
	
	
	
func _input(event):

	if event is InputEventMouseButton && event.is_pressed() && event.button_index == LEFT_MOUSE_BUTTON: 

		var target_position = get_world_position()		
		if target_position:
			navigation_agent.target_position = target_position
			
			#if (navigation_agent.get_current_navigation_path()):
				#print("--------------------")
				#print("get_current_navigation_path:")
				#for p in navigation_agent.get_current_navigation_path():
					#print(p) # Print each point in the calculated path
				#print("--------------------")


				
			#set_movement_target(target_position)
			
			#var new_path = get_navigation_path(target_position, global_position)
			#if new_path:
				#print("--------------------")
				#print("New Path Calculated:")
				#for p in new_path:
					#print(p) # Print each point in the calculated path
				#print("--------------------")
		
		
		
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
	
	if result:
		return result.position
	else:
		return null


# Update animations
func update_animations():

	var is_idle : bool = velocity.x == 0.0 && velocity.z == 0.0
	var is_walking : bool = velocity.x != 0.0 || velocity.z != 0.0
	
	animation_tree.set("parameters/conditions/idle", is_idle)
	animation_tree.set("parameters/conditions/walking", is_walking)
	#$AnimationTree.set("parameters/conditions/straifLeft", input_dir.x == -1 && is_on_floor())
	#$AnimationTree.set("parameters/conditions/straifRight", input_dir.x == 1 && is_on_floor())
	#$AnimationTree.set("parameters/conditions/falling", !is_on_floor())
	#$AnimationTree.set("parameters/conditions/landed", is_on_floor())



# Basic query for a navigation path using the default navigation map.
func get_navigation_path(p_start_position: Vector3, p_target_position: Vector3) -> PackedVector3Array:

	print_debug("get_navigation_path")
	if not is_inside_tree():
		return PackedVector3Array()

	var default_map_rid: RID = get_world_3d().get_navigation_map()
	print_debug(default_map_rid)
	var path: PackedVector3Array = NavigationServer3D.map_get_path(
		default_map_rid,
		p_start_position,
		p_target_position,
		true
	)
	return path


func set_movement_target(target_position: Vector3):

	var start_position: Vector3 = global_transform.origin

	current_path = NavigationServer3D.map_get_path(
		default_3d_map_rid,
		start_position,
		target_position,
		true
	)

	if not current_path.is_empty():
		current_path_index = 0
		current_path_point = current_path[0]
		
#	Callbacks
func _on_velocity_computed(safe_velocity: Vector3):
	#print("_on_velocity_computed : ", safe_velocity)
	velocity = safe_velocity
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)
	
