extends Resource
class_name AudioResource

# 音频资源管理
# 用于加载和管理游戏中的音频文件

enum AudioType {
	BGM,
	SFX
}

@export var audio_name: String
@export var audio_type: AudioType
@export var audio_path: String
@export var volume_db: float = 0.0
@export var pitch_scale: float = 1.0
@export var loop: bool = false

var audio_stream: AudioStream

func _init():
	load_audio()

func load_audio():
	if audio_path.is_empty():
		return

	if audio_path.ends_with(".ogg"):
		audio_stream = load(audio_path) as AudioStreamOggVorbis
	elif audio_path.ends_with(".mp3"):
		audio_stream = load(audio_path) as AudioStreamMP3
	elif audio_path.ends_with(".wav"):
		audio_stream = load(audio_path) as AudioStreamWAV

	if audio_stream:
		audio_stream.loop = loop

func get_stream() -> AudioStream:
	return audio_stream

func set_volume(db: float):
	volume_db = db

func set_pitch(pitch: float):
	pitch_scale = pitch
