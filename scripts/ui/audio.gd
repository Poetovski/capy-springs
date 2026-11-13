extends Node
## Музыка и звуки. Громкость берётся из настроек Game (music_vol / sfx_vol).

const MUSIC_PATH: String = "res://assets/music/cozy_loop.wav"
const MUSIC_BASE_DB: float = -4.0
const CHANNELS: int = 6

var music_player: AudioStreamPlayer
var snd_pop: AudioStream = preload("res://assets/pop.wav")
var snd_buy: AudioStream = preload("res://assets/buy.wav")
var snd_gold: AudioStream = preload("res://assets/gold.wav")
var _sfx: Array = []
var _next: int = 0


func _ready() -> void:
	for i in CHANNELS:
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(p)
		_sfx.append(p)
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	if not ResourceLoader.exists(MUSIC_PATH):
		return
	var s: AudioStream = load(MUSIC_PATH)
	if s is AudioStreamWAV:
		# Бесшовная петля
		var w: AudioStreamWAV = s
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = int(w.get_length() * w.mix_rate)
	music_player.stream = s
	apply_volumes()
	music_player.play()


func apply_volumes() -> void:
	if music_player == null:
		return
	var v: float = Game.music_vol
	music_player.volume_db = MUSIC_BASE_DB + linear_to_db(maxf(v, 0.0001))
	music_player.stream_paused = v <= 0.001


func play(stream: AudioStream, pitch: float = 1.0, db: float = 0.0) -> void:
	if stream == null or Game.sfx_vol <= 0.001:
		return
	var p: AudioStreamPlayer = _sfx[_next]
	_next = (_next + 1) % _sfx.size()
	p.stream = stream
	p.pitch_scale = pitch
	p.volume_db = db + linear_to_db(Game.sfx_vol)
	p.play()


func pop() -> void:
	play(snd_pop, randf_range(0.9, 1.2), -6.0)


func buy(pitch: float = 1.0) -> void:
	play(snd_buy, pitch * randf_range(0.95, 1.05), -4.0)


func gold(pitch: float = 1.0) -> void:
	play(snd_gold, pitch)
