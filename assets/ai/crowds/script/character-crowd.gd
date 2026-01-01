extends CharacterBody3D

const RAY_LENGTH = 1000
const LEFT_MOUSE_BUTTON = 1

const NAVIGATION_MARKER_GROUP = "NAVIGATION_MARKER"
const MAX_FLOAT_VALUE := 1.79769e308


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
#@onready var animation_tree : AnimationTree = get_node("Geometry/model/AnimationTree")
#@export var animation_tree : AnimationTree 
#@onready var camera = get_parent_node_3d().get_node("Camera3D")
@onready var camera = get_viewport().get_camera_3d()


@export var walking_speed : float = 3.0
@export var running_speed : float = 6.0


#
@onready var default_3d_map_rid: RID = get_world_3d().get_navigation_map()

var movement_delta: float
var path_point_margin: float = 0.5

var current_path_index: int = 0
var current_path_point: Vector3
var current_path: PackedVector3Array


var navigation_markers : Array =[]

# Called when the node enters the scene tree for the first time.
func _ready():
	#motion_mode = MOTION_MODE_GROUNDED

	print_debug("_ready")
	print_debug(get_tree().current_scene.name)
	#print_debug( get_tree().get_root().get_node(get_tree().current_scene.name + "Camera3D") )

	#pass # Replace with function body.

	navigation_markers = get_navigation_markers(NAVIGATION_MARKER_GROUP)
	#print(navigation_markers)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if(navigation_agent.is_navigation_finished() || !navigation_agent.is_target_reachable()):
		#print("Stopped")
		velocity = Vector3.ZERO
	else:
		#print("Moving...")
		move_to_point(delta, walking_speed)

	#update_animations()
		

func move_to_point(delta, speed):

	var target_pos = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(target_pos)
	
	face_to(target_pos)
	
	var new_velocity = direction * speed
	velocity = velocity.move_toward(new_velocity, delta * 2.5)
	
	move_and_slide()
	

func face_to(target_pos):

	#	Hard Turn
	#look_at(Vector3(target_pos.x, global_position.y, target_pos.z), Vector3.UP)
	#	Soft Turn
	var new_direction: Vector3 = self.global_position.direction_to(Vector3(target_pos.x, global_position.y, target_pos.z))
	var target: Basis = Basis.looking_at(new_direction)
	basis = basis.slerp(target, 0.1)
	
	
	
func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventKey :
		if event.pressed and not event.echo:
			if event.keycode == KEY_N:
				print("Asked new navigation point")
				var target_position = get_closest_navigation_marker()
				print(target_position)
				target_position.y=0.5
				if target_position:
					navigation_agent.target_position = target_position
					
					var target_pos = navigation_agent.get_next_path_position()
					print(target_pos)
					print(navigation_agent.is_target_reachable())
					
					var new_path = get_navigation_path(target_position, global_position)
					if new_path:
						print("--------------------")
						print("New Path Calculated:")
						for p in new_path:
							print(p) # Print each point in the calculated path
						print("--------------------")

	if event is InputEventMouseButton && event.is_pressed() && event.button_index == LEFT_MOUSE_BUTTON: 

		var target_position = get_world_position()		
		if target_position:
			navigation_agent.target_position = target_position
			
			var new_path = get_navigation_path(target_position, global_position)
			if new_path:
				print("--------------------")
				print("New Path Calculated:")
				for p in new_path:
					print(p) # Print each point in the calculated path
				print("--------------------")
		
		
		
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
#func update_animations():
#
	#var is_idle : bool = velocity.x == 0.0 && velocity.z == 0.0
	#var is_walking : bool = velocity.x != 0.0 || velocity.z != 0.0
	#
	##print(velocity)
	##print(is_on_floor())
	##print(is_idle)
	##print(is_walking)
	#
	#animation_tree.set("parameters/conditions/idle", is_idle)
	#animation_tree.set("parameters/conditions/walking", is_walking)
	##$AnimationTree.set("parameters/conditions/straifLeft", input_dir.x == -1 && is_on_floor())
	##$AnimationTree.set("parameters/conditions/straifRight", input_dir.x == 1 && is_on_floor())
	##$AnimationTree.set("parameters/conditions/falling", !is_on_floor())
	##$AnimationTree.set("parameters/conditions/landed", is_on_floor())



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
		

func get_navigation_markers(group_name) -> Array[Node]:
	return get_tree().get_nodes_in_group(group_name)

func get_closest_navigation_marker() -> Vector3:
	
	var closest_distance : float = MAX_FLOAT_VALUE
	var closes_marker : Node3D
	for marker in navigation_markers:
		var distance : float = (marker as Node3D).global_position.distance_squared_to(global_position)
		if distance < closest_distance:
			closest_distance = distance
			closes_marker = marker	
			
	return closes_marker.global_position
		
