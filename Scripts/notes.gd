extends PanelContainer
var pen = false
@onready var pen_cursor: Sprite2D = $"../../../PenCursor"

func _on_pen_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	pen = true


func _on_edit_text_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pen = false


func _on_gum_pressed() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if pen:
		pen_cursor.global_position = get_global_mouse_position()
	else:
		pen_cursor.global_position = Vector2(-10,-10)
