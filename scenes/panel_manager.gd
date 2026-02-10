extends MarginContainer

var panels: Array[PanelContainer] = []
@onready var planning: Button = %Planning
@onready var button_2: Button = %Button2
@onready var button_3: Button = %Button3
@onready var button_4: Button = %Button4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panels = [
		%PlanningContainer, %PanelContainer2, %PanelContainer3, %PanelContainer4
	]
	
	planning.pressed.connect(show_panel.bind(panels[0]))
	button_2.pressed.connect(show_panel.bind(panels[1]))
	button_3.pressed.connect(show_panel.bind(panels[2]))
	button_4.pressed.connect(show_panel.bind(panels[3]))
	
	show_panel(panels[1])
	planning.grab_focus()
# Called every frame. 'delta' is the elapsed time since the previous frame.
	
func _process(delta: float) -> void:
	pass

func show_panel(panel_to_show: PanelContainer) -> void:
	for panel in panels:
		panel.hide()
		
	panel_to_show.show()
