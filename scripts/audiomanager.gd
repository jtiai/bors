extends Node

var num_channels = 5

var available = []
var queue = []

var music_player: AudioStreamPlayer
var playlist = []
var played = []

func _ready():
	randomize()

	process_mode = Node.PROCESS_MODE_ALWAYS

	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	music_player.connect("finished",Callable(_on_music_finished).bind(music_player))

	for i in num_channels:
		var sound_player = AudioStreamPlayer.new()
		sound_player.bus = "Sfx"
		add_child(sound_player)
		available.append(sound_player)
		var _val = sound_player.connect("finished",Callable(_on_stream_finished).bind(sound_player))


func _on_music_finished(_stream):
	var previous_song = playlist.pop_back()
	played.append(previous_song)
	play_music(previous_song)


func queue_music(sound_path):
	playlist.append(sound_path)


func shuffle_music_queue():
	playlist.shuffle()


func _on_stream_finished(stream):
	free_stream(stream)


func play_sound(resource):
	if not available.is_empty():
		var p = available.pop_front()
		p.stream = resource
		p.play()
		return p
	else:
		queue.append(resource)
	return null


func free_stream(stream):
	available.append(stream)


func start_music():
	_on_music_finished(music_player)


func play_music(resource):
	if music_player.playing:
		music_player.stop()
	music_player.stream = resource
	music_player.play()


func get_music_stream():
	return music_player


func _on_songs_played():
	var last = played.pop_back()
	played.shuffle()
	playlist = played
	playlist.append(last)
	played = []


func _process(_delta):
	if not queue.is_empty() and not available.is_empty():
		var p = available.pop_front()
		var s = queue.pop_front()
		p.stream = s
		p.play()
