extends Resource
class_name GameConfig

# 游戏配置
# 集中管理游戏中的各种参数和设置

# 情绪阶段配置
@export var emotion_duration: float = 30.0  # 每个情绪阶段的持续时间（秒）

# 碎片配置
@export var max_fragments: int = 500  # 最大碎片数量
@export var fragment_spawn_rate: float = 1.0  # 碎片生成速率
@export var fragment_speed: float = 100.0  # 碎片移动速度

# 玩家配置
@export var player_move_speed: float = 300.0  # 玩家移动速度
@export var pulse_radius: float = 200.0  # 脉冲半径
@export var pulse_force: float = 500.0  # 脉冲力度
@export var pulse_cooldown: float = 1.0  # 脉冲冷却时间

# 视觉效果配置
@export var particle_amount: int = 50  # 粒子数量
@export var particle_lifetime: float = 1.0  # 粒子生命周期
@export var glow_intensity: float = 0.5  # 发光强度
@export var noise_intensity: float = 0.3  # 噪点强度

# 音频配置
@export var bgm_volume: float = -10.0  # 背景音乐音量
@export var sfx_volume: float = -5.0  # 音效音量
@export var audio_max_distance: float = 500.0  # 音效最大距离

# 情绪阈值配置
@export var chaos_threshold: float = 50.0  # 进入混乱状态的希望值阈值
@export var refactor_threshold: float = 70.0  # 进入重构状态的焦虑和控制值阈值

# 游戏难度配置
@export var difficulty_multiplier: float = 1.0  # 难度倍数
@export var chaos_increase_rate: float = 1.0  # 混乱值增加速率
@export var hope_increase_rate: float = 1.0  # 希望值增加速率

func get_difficulty_adjusted_value(base_value: float) -> float:
	# 根据难度倍数调整值
	return base_value * difficulty_multiplier

func reset_to_defaults():
	# 重置为默认值
	emotion_duration = 30.0
	max_fragments = 500
	fragment_spawn_rate = 1.0
	fragment_speed = 100.0
	player_move_speed = 300.0
	pulse_radius = 200.0
	pulse_force = 500.0
	pulse_cooldown = 1.0
	particle_amount = 50
	particle_lifetime = 1.0
	glow_intensity = 0.5
	noise_intensity = 0.3
	bgm_volume = -10.0
	sfx_volume = -5.0
	audio_max_distance = 500.0
	chaos_threshold = 50.0
	refactor_threshold = 70.0
	difficulty_multiplier = 1.0
	chaos_increase_rate = 1.0
	hope_increase_rate = 1.0
