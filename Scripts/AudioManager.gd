extends Node

# 音频管理器
# 负责处理游戏中的背景音乐和音效

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var sfx_player: AudioStreamPlayer2D = $SFXPlayer

# 音频配置
var base_pitch: float = 1.0
var target_pitch: float = 1.0

# 信号
signal audio_state_changed(state: String)

func _ready():
	print("音频管理器初始化完成")
	setup_audio_players()

func setup_audio_players():
	# 创建背景音乐播放器
	if not bgm_player:
		bgm_player = AudioStreamPlayer.new()
		add_child(bgm_player)

	bgm_player.bus = "Master"
	bgm_player.volume_db = -10.0

	# 创建音效播放器
	if not sfx_player:
		sfx_player = AudioStreamPlayer2D.new()
		add_child(sfx_player)

	sfx_player.bus = "Master"
	sfx_player.volume_db = -5.0
	sfx_player.max_distance = 500.0

func play_bgm(stream: AudioStream):
	if bgm_player and stream:
		bgm_player.stream = stream
		bgm_player.play()

func stop_bgm():
	if bgm_player:
		bgm_player.stop()

func play_sfx(stream: AudioStream, position: Vector2 = Vector2.ZERO):
	if sfx_player and stream:
		sfx_player.stream = stream
		sfx_player.global_position = position
		sfx_player.play()

func update_pitch_based_on_anxiety(anxiety_value: float):
	# 根据焦虑值调整音调
	# 焦虑值越高，音调越高，营造紧张感
	target_pitch = base_pitch + (anxiety_value / 100.0) * 0.5

	if bgm_player:
		bgm_player.pitch_scale = lerp(bgm_player.pitch_scale, target_pitch, 0.1)

func play_pulse_sound(position: Vector2):
	# 创建脉冲音效
	var pulse_sound = create_pulse_audio_stream()
	play_sfx(pulse_sound, position)

func play_collision_sound(position: Vector2):
	# 创建碰撞音效
	var collision_sound = create_collision_audio_stream()
	play_sfx(collision_sound, position)

func create_pulse_audio_stream() -> AudioStream:
	# 创建简单的脉冲音效
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100.0
	generator.buffer_length = 0.1

	return generator

func create_collision_audio_stream() -> AudioStream:
	# 创建简单的碰撞音效
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100.0
	generator.buffer_length = 0.05

	return generator

func _process(delta: float):
	# 平滑过渡音调
	if bgm_player and abs(bgm_player.pitch_scale - target_pitch) > 0.01:
		bgm_player.pitch_scale = lerp(bgm_player.pitch_scale, target_pitch, delta * 2.0)
