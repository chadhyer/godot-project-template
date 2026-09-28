class_name TitleScene extends Scene


# Temp
var next_scene:PackedScene = null

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		## FUTURE (title) Add transition animation
		# for now we request main to change scene
		if next_scene:
			emit_scene_update_request(next_scene)
		else:
			queue_free()
