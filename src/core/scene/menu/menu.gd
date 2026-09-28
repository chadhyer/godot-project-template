class_name MenuScene extends Scene

@onready var canvas_layer: CanvasLayer = %CanvasLayer

var allow_menu_toggle = true

# GAME BUTTONS
@onready var quit_game_button: Button = %QuitGameButton

# VIDEO BUTTONS
# AUDIO BUTTONS

# DEV BUTTONS
const dev_world_path:="res://src/world/dev/"
@onready var dev: VBoxContainer = %Dev


func _ready() -> void:
	# GAME
	quit_game_button.button_down.connect(_on_quit_game_pressed)
	# VIDEO
	# AUDIO
	# DEV
	list_world_dev()


func _input(event: InputEvent) -> void:
	if allow_menu_toggle and event.is_action_pressed("ToggleMenu"):
		canvas_layer.visible = !canvas_layer.visible


# GAME
func _on_quit_game_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


# VIDEO
# AUDIO
# DEV
func list_world_dev() -> void:
	var dev_dir := DirAccess.get_files_at(dev_world_path)
	for file in dev_dir:
		if file.ends_with('tscn'):
			var button := Button.new()
			button.text = file.replace(".tscn","")
			dev.add_child(button)
			button.pressed.connect(func():
				scene_update_request.emit(load(dev_world_path + file)))
