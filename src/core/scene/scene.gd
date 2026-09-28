@abstract
class_name Scene extends Node

signal scene_update_request(new_scene:PackedScene)

@onready var entity_root: Node3D = %EntityRoot
@onready var effect_root: Node3D = %EffectRoot


func emit_scene_update_request(new_scene:PackedScene) -> void:
	scene_update_request.emit(new_scene)
