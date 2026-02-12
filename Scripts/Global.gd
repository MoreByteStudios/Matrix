extends Control


var all_tasks : Array = []
var start_tab : int = 0
const SAVE_PATH = "user://planner_data.json"

func _ready():
	get_tree().set_auto_accept_quit(false)
	load_data()

func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data_to_save = {
		"tasks": all_tasks,
	}
	var json_string = JSON.stringify(data_to_save)

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	var data = JSON.parse_string(content)
	
	if data:
		all_tasks = data.get("tasks", [])
		# Laad de opgeslagen naam terug in de variabele

func _process(delta):
	# Zorgt dat er nog snel opgeslagen wordt als je het venster sluit

	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
