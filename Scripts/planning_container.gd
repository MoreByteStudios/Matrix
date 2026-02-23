extends PanelContainer

var current_links: Array = [] # Tijdelijke lijst voor links
var margincontainers: Array[MarginContainer] = []
var temp_file_paths : Array = []
var target_type: String = "Planning"
var target_day: int = -1
var current_task_data = null  
var selected_color: Color = Color("4d4d4d")

@onready var DetailTab: PanelContainer = $"../../../DetailTab"
@onready var tasks_button: Button = %TasksButton
@onready var agenda_button: Button = %AgendaButton
@onready var school_planning: Button = %SchoolPlanning
@onready var vandaag_button: Button = %VandaagButton
@onready var maand_button: Button = %MaandButton
@onready var previos_button: Button = $HBoxContainer2/AgendaUI/AngendaVbox/WeekDatumContainer/PreviosButton
@onready var next_button: Button = $HBoxContainer2/AgendaUI/AngendaVbox/WeekDatumContainer/NextButton
@onready var vandaag_container: PanelContainer = %VandaagContainer
@onready var maand_container: PanelContainer = %MaandContainer
@onready var Add_task_to_monday_button: Button = %PlanningListMaandagAdderTask
@onready var Save_task: Button = %SaveButton
@onready var Task_Add_Tab: PanelContainer = $"../../../TaskAddTab"
@onready var week_containers = [
	$HBoxContainer2/AgendaUI/AngendaVbox/DagenContainers/Maandag, 
	$HBoxContainer2/AgendaUI/AngendaVbox/DagenContainers/Dinsdag, 
	$HBoxContainer2/AgendaUI/AngendaVbox/DagenContainers/Woensdag, 
	$HBoxContainer2/AgendaUI/AngendaVbox/DagenContainers/Donderdag, 
	$HBoxContainer2/AgendaUI/AngendaVbox/DagenContainers/Vrijdag, 
	$HBoxContainer2/AgendaUI/AngendaVbox/DagenContainers/Zaterdag,
	$HBoxContainer2/AgendaUI/AngendaVbox/DagenContainers/Zondag
]
@export var maand_titel_label: Label
@export var dagnaam_labels: Array[Label] # Voor "Maandag"
@export var getal_labels: Array[Label]   # Voor "1"

var week_offset = 0 # 0 is deze week, 1 is volgende week, -1 is vorige week
var dag_namen = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
var maand_namen = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "Oktober", "November", "December"]

var press_count2 = 0
var press_count1 = 0

@onready var task_bar_scene = preload("uid://cn63lfysnxatm")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	margincontainers = [
		%TasksUi, %AgendaUI, %Schoolplanning
	]
	
	tasks_button.pressed.connect(show_margincontainer.bind(margincontainers[0]))
	agenda_button.pressed.connect(show_margincontainer.bind(margincontainers[1]))
	school_planning.pressed.connect(show_margincontainer.bind(margincontainers[2]))
	
	show_margincontainer(margincontainers[1])
# Called every frame. 'delta' is the elapsed time since the previous frame.
	
	vandaag_container.hide()
	maand_container.hide()
	$"../../../TaskAddTab".hide()
	
	update_agenda()
	
func _process(delta: float) -> void:
	if %TasksUi.visible:
		vandaag_container.hide()
		maand_container.hide()
		if press_count1 == 0:
			pass
		if press_count1 == 1:
			press_count1 -= 1
		if press_count1 == 2:
			press_count1 -= 2
		if press_count2 == 0:
			pass
		if press_count2 == 1:
			press_count2 -= 1
		if press_count2 == 2:
			press_count2 -= 2
	if %Schoolplanning.visible:
		vandaag_container.hide()
		maand_container.hide()
		if press_count1 == 0:
			pass
		if press_count1 == 1:
			press_count1 -= 1
		if press_count1 == 2:
			press_count1 -= 2
		if press_count2 == 0:
			pass
		if press_count2 == 1:
			press_count2 -= 1
		if press_count2 == 2:
			press_count2 -= 2

func show_margincontainer(margincontainer_to_show: MarginContainer) -> void:
	for margincontainer in margincontainers:
		margincontainer.hide()
	
	margincontainer_to_show.show()


func _on_vandaag_button_pressed() -> void:
	if vandaag_button.pressed:
		vandaag_container.show()
		maand_container.hide()
		press_count1 += 1
		if press_count2 == 0:
			pass
		if press_count2 == 1:
			press_count2 -= 1
		if press_count2 == 2:
			press_count2 -= 2
		if press_count1 == 2:
			vandaag_container.hide()
			press_count1 -= 2
		
func _on_maand_button_pressed() -> void:
	if maand_button.pressed:
		maand_container.show()
		vandaag_container.hide()
		press_count2 += 1
		if press_count1 == 0:
			pass
		if press_count1 == 1:
			press_count1 -= 1
		if press_count1 == 2:
			press_count1 -= 2
		if press_count2 == 2:
			maand_container.hide()
			press_count2 -= 2

func _on_close_button_pressed() -> void:
	if %CloseButton.pressed:
		vandaag_container.hide()
		press_count1 -= 1


func _on_close_button_2_pressed() -> void:
	if %CloseButton2.pressed:
		maand_container.hide()
		press_count2 -= 1

func update_agenda():
	var nu = Time.get_date_dict_from_system()
	var nu_unix = Time.get_unix_time_from_system()
	
	# Bereken maandag van de geselecteerde week
	var dagen_verschil_met_maandag = nu.weekday - 1
	if dagen_verschil_met_maandag == -1: 
		dagen_verschil_met_maandag = 6
		
	var maandag_unix = nu_unix - (dagen_verschil_met_maandag * 86400) + (week_offset * 7 * 86400)

	# 1. Update de algemene maandtitel (gebaseerd op de maandag van die week)
	var eerste_dag_data = Time.get_date_dict_from_unix_time(maandag_unix)
	maand_titel_label.text = maand_namen[eerste_dag_data.month - 1] + " " + str(eerste_dag_data.year)

	# 2. Vul de 7 dag- en getallabels
	for i in range(7):
		var dag_unix = maandag_unix + (i * 86400)
		var d = Time.get_date_dict_from_unix_time(dag_unix)
		
		# Check of de arrays in de Inspector wel 7 labels hebben!
		if i < dagnaam_labels.size() and i < getal_labels.size():
			dagnaam_labels[i].text = dag_namen[d.weekday]
			getal_labels[i].text = str(d.day)

func _on_next_button_pressed() -> void:
	week_offset += 1
	update_agenda()

func _on_previos_button_pressed() -> void:
	week_offset -= 1
	update_agenda()


func _on_planning_list_maandag_adder_task_pressed() -> void:
	$"../../../TaskAddTab".show()

func _on_deadline_list_maandag_adder_task_pressed() -> void:
	pass # Replace with function body.
	
func _on_save_pressed():
	var TaskAddTab = $"../../../TaskAddTab"
	var t_node = TaskAddTab.find_child("TitleInput", true, false)
	var d_node = TaskAddTab.find_child("DetailInput", true, false)
	var l_node = TaskAddTab.find_child("LinkInput", true, false) # Zorg dat dit een TextEdit is!
	var links_lijst = []
	
	if l_node and l_node.text != "":
		current_links.append(l_node.text)
		var link_text = l_node.text
		if not link_text.begins_with("http"): 
			link_text = "https://" + link_text
		if not temp_file_paths.has(link_text):
			temp_file_paths.append(link_text)
		l_node.text = "" # Maak het veld weer leeg
		links_lijst = l_node.text.split("\n", false)
	var final_deadline = 0
	# Bepaal de deadline
	if target_type == "Deadline":
		var current_dt = Time.get_datetime_dict_from_system()
		var current_unix = Time.get_unix_time_from_system()
		var days_to_monday = current_dt.weekday - 1
		var monday_unix = current_unix - (days_to_monday * 86400)
		final_deadline = int(monday_unix + (target_day * 86400))
	else:
		final_deadline = get_timestamp_from_ui()
	if current_task_data:
		# Bewerken
		current_task_data["TitleInput"] = t_node.text
		current_task_data["DetailInput"] = d_node.text if d_node else ""
		current_task_data["VboxContainer2"] = selected_color.to_html()
		current_task_data["FileInput"] = temp_file_paths.duplicate()
	else:
		# NIEUW: Maar één keer append gebruiken!
		var new_task = {
			"TitleInput": t_node.text,
			"DetailInput": d_node.text if d_node else "",
			"VBoxContainer2": selected_color.to_html(),
			"deadline": get_timestamp_from_ui(),
			"day_index": int(target_day),
			"type": target_type,
			"file_paths": temp_file_paths.duplicate(),
			"completed": false
		}
		Global.all_tasks.append(new_task)

	Global.save_data()
	TaskAddTab.hide()
	temp_file_paths = []
	target_day = -1 
	
	# Ververs ALLES
	refresh_all_views()
	refresh_project_list()
	refresh_all_views() # Dit ververst de week én de today-tab tegelijk	
	
func get_timestamp_from_ui() -> int:
	var d_node = Task_Add_Tab.find_child("Date", true, false)
	var m_node = Task_Add_Tab.find_child("Month", true, false)
	var y_node = Task_Add_Tab.find_child("Year", true, false)
	
	var d = int(d_node.text) if d_node and d_node.text != "" else 1
	var m = int(m_node.text) if m_node and m_node.text != "" else 1
	var y = int(y_node.text) if y_node and y_node.text != "" else 2025
	
	var date_dict = {"year": y, "month": m, "day": d, "hour": 12, "minute": 0, "second": 0}
	return Time.get_unix_time_from_datetime_dict(date_dict)

func refresh_project_list():
	var project_container = find_child("ProjectListContainer", true, false)
	if not project_container: return
	
	_clear_and_prep_container(project_container)
	
	for task in Global.all_tasks:
		# Projecten hebben vaak geen dag_index (of -1)
		if task.get("day_index", -1) == -1:
			_add_task_to_specific_container(task, project_container)

func refresh_all_views():
	# Loop door de 7 week containersx (Ma t/m Zo)
	for i in range(week_containers.size()):
		var container = week_containers[i]
		var p_list = container.find_child("PlanningContainer", true, false)
		var d_list = container.find_child("DeadlineContainer", true, false)
		
		if p_list: _clear_and_prep_container(p_list)
		if d_list: _clear_and_prep_container(d_list)
		
		for task in Global.all_tasks:
			if task.get("day_index", -1) == i:
				if task.get("type") == "Deadline":
					_add_task_to_specific_container(task, d_list)
				else:
					_add_task_to_specific_container(task, p_list)
	
	# Ververs de rest van de schermen
	refresh_project_list()

func _clear_and_prep_container(container):
	for c in container.get_children(): 
		c.queue_free()
	
	# Spacer voor de look
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 15 
	container.add_child(spacer)

func _add_task_to_specific_container(data: Dictionary, container: Node):
	var new_bar = task_bar_scene.instantiate()
	container.add_child(new_bar)
	
	var label = new_bar.find_child("Label", true, false)
	var dl_label = new_bar.find_child("DeadlineLabel", true, false)
	var emoji = new_bar.find_child("Emoji", true, false)
	
	# Toon de TITEL
	if label:
		label.text = data.get("Title", "Naamloos")
	
	# Kleur van de COLORBAR (het balkje zelf)
	if data.has("task_color"):
		new_bar.self_modulate = Color.from_string(data.task_color, Color.GRAY)
	
	# KLOK-KLEUR logica
	if data.has("deadline") and data.deadline > 0:
		var info = get_deadline_info(data.deadline)
		if dl_label: dl_label.text = info.text
		if emoji:
			emoji.text = "🕒"
			match info.color:
				"Red": emoji.modulate = Color.RED
				"Orange": emoji.modulate = Color.ORANGE
				"Green": emoji.modulate = Color.GREEN
				"Blue": emoji.modulate = Color.BLUE
				_: emoji.modulate = Color.WHITE

	# Klikken om details te openen
	new_bar.pressed.connect(func(): show_detail(data)) 

func get_deadline_info(deadline_ts: int) -> Dictionary:
	var nu = Time.get_unix_time_from_system()
	var verschil = deadline_ts - nu
	
	var result = {"text": "Gepland", "color": "green"}
	
	if verschil < 0:
		result.text = "Verlopen"
		result.color = "red"
	elif verschil < 86400: # Minder dan 24 uur (Vandaag)
		result.text = "Vandaag"
		result.color = "orange"
	else:
		result.text = "Toekomst"
		result.color = "green"
		
	return result
	
func show_detail(data: Dictionary):
	current_task_data = data
	
	# 1. Zoek de nodes in de DetailPopup
	var t_node = DetailTab.find_child("Title", true, false)
	var d_node = DetailTab.find_child("Description", true, false)
	var dl_node = DetailTab.find_child("DeadlineLable", true, false)
	var list_container = DetailTab.find_child("Files", true, false)
	
	# 2. Vul de Titel in
	if t_node: 
		t_node.text = data.get("Title", "Naamloze taak")
	
	# 3. Vul de Beschrijving in (DIT IS WAT JE ZOCHT)
	if d_node: 
		var beschrijving = data.get("Description", "")
		if beschrijving == "":
			d_node.text = "Geen beschrijving beschikbaar."
		else:
			d_node.text = beschrijving
		
		# Zorg dat de tekst mooi afbreekt als het een Label is
		if d_node is Label:
			d_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# 4. Deadline info tonen
	# Deadline met JAAR tonen in Detail paneel
	
	if t_node: t_node.text = data.get("Title", "Naamloos")
	if d_node: d_node.text = data.get("Description", "Geen beschrijving.")

	if dl_node:
		if data.has("deadline") and data.deadline > 0:
			var d = Time.get_datetime_dict_from_unix_time(data.deadline)
			# Formaat: Dag-Maand-Jaar (bijv. 21-01-2026)
			var datum_met_jaar = "%02d-%02d-%04d" % [d.day, d.month, d.year]
			
			var dl_info = get_deadline_info(data.deadline)
			dl_node.text = "Deadline: " + datum_met_jaar
			dl_node.modulate = dl_info.color # Kleur van de tekst (Rood/Oranje/Groen)
		else:
			dl_node.text = "Geen deadline"
			dl_node.modulate = Color.WHITE
	# 5. Bestanden en Links verversen
	if list_container:
		for child in list_container.get_children():
			child.queue_free()
			
		var paths = data.get("file_paths", [])
		for path in paths:
			var link = LinkButton.new()
			if path.begins_with("http"):
				link.text = "🔗 " + path
			else:
				link.text = "📂 " + path.get_file()
			
			link.pressed.connect(func(): OS.shell_open(path))
			list_container.add_child(link)
	
	# Toon de popup
	$"../../../DetailTab".show()
