extends Button

# Deze variabele houdt alle info van de taak bij (Titel, Beschrijving, etc.)
var task_data = {}

func _ready():
	# Als de knop wordt ingedrukt, sturen we de data naar het hoofdmenu
	pressed.connect(_on_task_pressed)

func _on_task_pressed():
	# Let op: Zorg dat je hoofd-node in je scene echt "Main" heet!
	var main_node = get_tree().root.find_child("Main_scene", true, false)
	if main_node:
		main_node.show_detail(task_data)

func set_task_data(data):
	task_data = data
