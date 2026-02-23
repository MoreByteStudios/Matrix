extends Control


var all_tasks : Array = []
var start_tab : int = 0
const SAVE_PATH = "user://planner_data.json"

func _ready():
	get_tree().set_auto_accept_quit(false)
	load_data()
	
func _process(delta):
	# Zorgt dat er nog snel opgeslagen wordt als je het venster sluit

	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
func save_data():
	pass

func load_data():
	pass
