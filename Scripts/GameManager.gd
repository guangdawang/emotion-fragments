extends Node2D

# 游戏管理器
# 负责管理游戏的整体状态和各个系统之间的协调

# 引用其他管理器
@onready var player_controller: Node2D = $Player
@onready var fragment_manager: Node = $FragmentManager
@onready var visual_effects: Node = $VisualEffects
@onready var audio_manager: Node = $AudioManager

# 游戏状态枚举
enum EmotionState {
	ORDER,      # 秩序/压抑
	CHAOS,      # 混乱/焦虑
	REFACTOR    # 重构/希望
}

# 全局变量
var current_state: EmotionState = EmotionState.ORDER
var hope_value: float = 0.0
var anxiety_value: float = 0.0
var control_value: float = 0.0

# 信号
signal state_changed(new_state: EmotionState)
signal hope_changed(value: float)
signal anxiety_changed(value: float)
signal control_changed(value: float)
signal game_started
signal game_paused
signal game_resumed
signal game_over

func _ready():
	print("游戏管理器初始化完成")
	setup_connections()
	setup_initial_state()
	initialize_game()

func setup_connections():
	# 连接玩家控制器信号
	if player_controller:
		player_controller.player_moved.connect(_on_player_moved)
		player_controller.pulse_activated.connect(_on_pulse_activated)
		player_controller.fragment_placed.connect(_on_fragment_placed)

	# 连接碎片管理器信号
	if fragment_manager:
		fragment_manager.fragment_created.connect(_on_fragment_created)
		fragment_manager.fragment_destroyed.connect(_on_fragment_destroyed)

	# 连接视觉特效信号
	if visual_effects:
		visual_effects.effect_triggered.connect(_on_effect_triggered)

func initialize_game():
	# 初始化游戏状态
	print("游戏初始化中...")
	emit_signal("game_started")

func setup_initial_state():
	# 初始化秩序阶段
	current_state = EmotionState.ORDER
	hope_value = 0.0
	anxiety_value = 0.0
	control_value = 0.0
	emit_signal("state_changed", current_state)

func transition_to_state(new_state: EmotionState):
	if current_state != new_state:
		current_state = new_state
		emit_signal("state_changed", current_state)
		print("状态转换: ", EmotionState.keys()[current_state])

func add_hope(amount: float):
	hope_value = clamp(hope_value + amount, 0.0, 100.0)
	emit_signal("hope_changed", hope_value)

func add_anxiety(amount: float):
	anxiety_value = clamp(anxiety_value + amount, 0.0, 100.0)
	emit_signal("anxiety_changed", anxiety_value)

func add_control(amount: float):
	control_value = clamp(control_value + amount, 0.0, 100.0)
	emit_signal("control_changed", control_value)

func _input(event):
	# R键重新开始游戏
	if event.is_action_pressed("ui_accept"):
		reset_game()

func reset_game():
	setup_initial_state()
	print("游戏已重置")
