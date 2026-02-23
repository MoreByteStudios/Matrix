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

@onready var task_bar_scene = preload("res://scenes/TaskBar.tscn")
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
	
func _on_save_button_pressed() -> void:
	if %SaveButton.pressed:
		Task_Add_Tab.hide()
	else:
		Task_Add_Tab.show()
	#get_tree().root # Access via scene main loop.
	#get_node("res://scenes/TaskBar.tscn") # Access via absolute path.
