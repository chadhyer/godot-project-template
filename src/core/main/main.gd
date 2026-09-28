class_name Main extends Node
## Main entry point for the game
## Responsible for setting up the world layers and coordinating high-level systems.

# FUTURE (main menu): Load test level for prototype
@export var player_scene:PackedScene
@export var world_scene:PackedScene

var player:Player = null
var _current_world:BaseWorld = null

# Game World Root Nodes
@onready var world_root: Node3D = %WorldRoot
@onready var entity_root: Node3D = %EntityRoot
@onready var effect_root: Node3D = %EffectRoot


func _ready() -> void:
	_init_player()
	load_world(world_scene)


## Instantiates the player and adds it to the entity layer
func _init_player() -> void:
	if ! player_scene:
		push_error('Could not load player scene: ' + str(player_scene))
		return
	player = player_scene.instantiate() as Player
	if ! player:
		push_error('Loaded player scene does not extend player or DNE: ' + str(player_scene))
		return
	entity_root.add_child(player)


## Called for loading a world scene.
## NOTE: The input world_scene must extend BaseWorld
func load_world(world_scene:PackedScene) -> void:
	# Make sure this is called during idle time
	_deferred_load_world.call_deferred(world_scene)


func _deferred_load_world(world_scene:PackedScene) -> void:
	if _current_world:
		_current_world.queue_free()
		_current_world = null
		# Allow the old world to finish freeing before adding the new one
		await get_tree().process_frame

	if ! world_scene:
		push_error('Could not load world as a packed scene: ' + str(world_scene))
	
	var new_world:Node = world_scene.instantiate()
	if ! _current_world is BaseWorld:
		new_world.free() # world must be removed from the tree
		push_error('Loaded world is not of type BaseWorld: ' + str(world_scene))
		return
	# FUTURE (main menu): Should have a fall back scene

	_current_world = new_world as BaseWorld
	world_root.add_child(_current_world)
	# Allow world to fully process before accessing it
	await get_tree().process_frame

	_place_player_at_world_spawn()
	_setup_world_camera()


## Finds the default spawn location in currently loaded world, and places
##  the Player at that position
func _place_player_at_world_spawn() -> void:
	if ! player:
		push_error('Cannot place player in world because it is null')
		return
	if ! _current_world:
		push_error('Cannot place player into world because world is null')
		return
	player.global_position = _current_world.get_default_player_spawn()


## Attaches player to the current camera as the target
func _setup_world_camera() -> void:
	if ! player or ! _current_world:
		return
	var world_camera:Camera3D = _current_world.get_player_camera()
	if ! world_camera:
		return
	# FUTURE (camera): Temporary hookup
	# Will become: camera_system.set_target(player)
	world_camera.target = player
