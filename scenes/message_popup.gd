extends PanelContainer

enum SoundType {
	MESSAGE,
	ANNOUNCEMENT
}

@onready var label := $"CenterContainer/RichTextLabel"
@onready var message_sound := preload("res://sounds/message_ding.wav")
@onready var announcement_sound := preload("res://sounds/announcement_end.wav")

var message_queue = []
var showing_message := false

func _process(_delta):
	if message_queue.is_empty():
		return

	if not showing_message:
		var msg_data = message_queue.pop_front()

		display_message(msg_data[0], msg_data[1], msg_data[2])


func show_message(message: String, timeout: float, sound: SoundType = SoundType.MESSAGE) -> void:
	message_queue.append([message, timeout, sound])


func display_message(message: String, timeout: float, sound: SoundType) -> void:
	showing_message = true
	get_tree().paused = true  # Pause the game

	label.text = message

	if sound == SoundType.ANNOUNCEMENT:
		Audiomanager.play_sound(announcement_sound)
	else:
		Audiomanager.play_sound(message_sound)

	show()

	await get_tree().create_timer(timeout).timeout

	hide()
	get_tree().paused = false
	showing_message = false
