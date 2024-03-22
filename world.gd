extends Node2D

@export var next_level: PackedScene

@onready var level_complete = $CanvasLayer/LevelComplete

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	Events.level_complete.connect(show_level_complete)
	
func show_level_complete():
	level_complete.show()
	get_tree().paused = true
	if not next_level is PackedScene: return
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()


