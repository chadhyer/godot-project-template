class_name Main extends Node
## Main entry point for the game
## Responsible for setting up the world layers and coordinating high-level systems.

@export var player_scene:PackedScene
@export var title_scene:PackedScene
@export var menu_scene:PackedScene
@export var test_world_scene:PackedScene

var player:Player = null
var _current_scene:Scene = null
var _menu:MenuScene = null
var allow_menu_toggle:bool = true

@onready var scene_holder: Node = %SceneHolder
@onready var ui_root: Control = %UIRoot
@onready var menu_root: Control = %MenuRoot
@onready var transition_root: Control = %TransitionRoot


func _ready() -> void:
	load_scene(title_scene)
	_init_menu()
	await get_tree().process_frame
	if _current_scene:
		_current_scene.next_scene = test_world_scene


## Instantiate the main menu
func _init_menu() -> void:
	if menu_scene:
		_menu = menu_scene.instantiate()
		menu_root.add_child(_menu)
		_menu.canvas_layer.visible = false
		_menu.scene_update_request.connect(load_scene)


## Instantiate the player and adds it to the entity layer
#func _init_player() -> void:
	#if ! player_scene:
		#push_error('Could not load player scene: ' + str(player_scene))
		#return
	#player = player_scene.instantiate() as Player
	#if ! player:
		#push_error('Loaded player scene does not extend player or DNE: ' + str(player_scene))
		#return
	#entity_root.add_child(player)


## Called for loading a world scene.
func load_scene(scene:PackedScene) -> void:
	# Make sure this is called during idle time
	_deferred_load_world.call_deferred(scene)


func _deferred_load_world(scene:PackedScene) -> void:
	if _current_scene:
		_current_scene.scene_update_request.disconnect(load_scene)
		_current_scene.queue_free()
		_current_scene = null
		# Allow the old world to finish freeing before adding the new one
		await get_tree().process_frame

	if ! scene:
		push_error('Could not load world as a packed scene: ' + str(scene))
	
	var new_scene:Node = scene.instantiate()
	if ! new_scene is Scene:
		new_scene.free() # world must be removed from the tree
		push_error('Loaded scene is not of type Scene: ' + str(scene))
		return
	# FUTURE (main menu): Should have a fall back scene

	_current_scene = new_scene as Scene
	scene_holder.add_child(_current_scene)
	_current_scene.scene_update_request.connect(load_scene)
	# Allow new scene to fully process before accessing it
	await get_tree().process_frame

	#_place_player_at_world_spawn()
	#_setup_world_camera()


## Finds the default spawn location in currently loaded world, and places
##  the Player at that position
func _place_player_at_world_spawn() -> void:
	if ! player:
		push_error('Cannot place player in world because it is null')
		return
	if ! _current_scene:
		push_error('Cannot place player into world because world is null')
		return
	player.global_position = _current_scene.get_default_player_spawn()


## Attaches player to the current camera as the target
func _setup_world_camera() -> void:
	if ! player or ! _current_scene:
		return
	var world_camera:Camera3D = _current_scene.get_player_camera()
	if ! world_camera:
		return
	# FUTURE (camera): Temporary hookup
	# Will become: camera_system.set_target(player)
	world_camera.target = player
