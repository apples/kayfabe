extends VBoxContainer

var message_scene = preload("chat_message.tscn")

@onready var message_draft = %MessageDraft
@onready var message_history = %MessageContainer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_send_button_pressed() -> void:
	if message_draft.text == "":
		return
	var new_message = message_scene.instantiate()
	new_message.set_message(message_draft.text)
	message_history.add_child(new_message)
	message_draft.text = ""
	
