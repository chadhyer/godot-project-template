@abstract
class_name BaseWorld extends Node3D
## Abstract class for worlds

## Provides default global position for player to be placed in world
@abstract func get_default_player_spawn() -> Vector3

# FUTURE (camera): This should be moved out of world into camera system/manager
## Provides the camera used in the world
@abstract func get_player_camera() -> Camera3D
