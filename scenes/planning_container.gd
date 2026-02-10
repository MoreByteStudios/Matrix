extends PanelContainer

var margincontainers: Array[MarginContainer] = []

@onready var tasks_button: Button = %TasksButton
@onready var agenda_button: Button = %AgendaButton
@onready var school_planning: Button = %SchoolPlanning
@onready var vandaag_button: Button = %VandaagButton
@onready var maand_button: Button = %MaandButton
@onready var previos_button: Button = $HBoxContainer2/AgendaUI/AngendaVbox/WeekDatumContainer/PreviosButton
@onready var next_button: Button = $HBoxContainer2/AgendaUI/AngendaVbox/WeekDatumContainer/NextButton
@onready var vandaag_container: PanelContainer = %VandaagContainer
@onready var maand_container: PanelContainer = %MaandContainer

var press_count2 = 0
var press_count1 = 0
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
		
