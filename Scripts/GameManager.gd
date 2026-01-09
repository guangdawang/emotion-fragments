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

# 游戏计时器
var state_timer: float = 0.0
var state_duration: float = 30.0  # 每个状态持续30秒
var total_game_time: float = 0.0  # 总游戏时间

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

func _process(delta: float):
	# 更新状态计时器
	update_state_timer(delta)

	# 自动增加焦虑值（混乱阶段）
	if current_state == EmotionState.CHAOS:
		add_anxiety(delta * 2.0)

	# 自动减少控制值（混乱阶段）
	if current_state == EmotionState.CHAOS:
		add_control(-delta * 1.0)

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

	# 重置成就系统
	if AchievementSystem:
		AchievementSystem.reset_achievements()

func setup_initial_state():
	# 初始化秩序阶段
	current_state = EmotionState.ORDER
	hope_value = 0.0
	anxiety_value = 0.0
	control_value = 0.0
	state_timer = 0.0
	emit_signal("state_changed", current_state)

func update_state_timer(delta: float):
	state_timer += delta

	# 检查是否应该转换状态
	if state_timer >= state_duration:
		state_timer = 0.0
		transition_to_next_state()

func transition_to_next_state():
	match current_state:
		EmotionState.ORDER:
			# 从秩序阶段转换到混乱阶段
			if hope_value >= 30.0:
				transition_to_state(EmotionState.CHAOS)
		EmotionState.CHAOS:
			# 从混乱阶段转换到重构阶段
			if control_value >= 50.0 and anxiety_value >= 50.0:
				transition_to_state(EmotionState.REFACTOR)
		EmotionState.REFACTOR:
			# 重构阶段完成，游戏结束
			end_game()

func transition_to_state(new_state: EmotionState):
	if current_state != new_state:
		current_state = new_state
		emit_signal("state_changed", current_state)
		print("状态转换: ", EmotionState.keys()[current_state])

		# 更新视觉效果
		if visual_effects and visual_effects.has_method("update_emotion_color"):
			visual_effects.update_emotion_color(new_state)

func add_hope(amount: float):
	hope_value = clamp(hope_value + amount, 0.0, 100.0)
	emit_signal("hope_changed", hope_value)

	# 检查成就
	if hope_value >= 100.0 and AchievementSystem:
		AchievementSystem.unlock_achievement("hope_bearer")

	# 检查秩序守护者成就
	if current_state == EmotionState.ORDER and hope_value >= 50.0 and AchievementSystem:
		AchievementSystem.unlock_achievement("order_keeper")

func add_anxiety(amount: float):
	anxiety_value = clamp(anxiety_value + amount, 0.0, 100.0)
	emit_signal("anxiety_changed", anxiety_value)

	# 检查状态转换
	if current_state == EmotionState.ORDER and anxiety_value >= 50.0:
		transition_to_state(EmotionState.CHAOS)

func add_control(amount: float):
	control_value = clamp(control_value + amount, 0.0, 100.0)
	emit_signal("control_changed", control_value)

	# 检查成就
	if control_value >= 80.0 and AchievementSystem:
		AchievementSystem.unlock_achievement("chaos_master")

	# 检查状态转换
	if current_state == EmotionState.CHAOS and control_value >= 70.0 and anxiety_value >= 70.0:
		transition_to_state(EmotionState.REFACTOR)
		if AchievementSystem:
			AchievementSystem.unlock_achievement("refactor_expert")

func _input(event):
	# R键重新开始游戏
	if event.is_action_pressed("ui_accept"):
		reset_game()

func reset_game():
	setup_initial_state()
	print("游戏已重置")

func end_game():
	emit_signal("game_over")

	# 检查完美主义者成就
	if hope_value >= 100.0 and AchievementSystem:
		AchievementSystem.unlock_achievement("perfectionist")

	# 加载游戏结束场景
	var game_over_scene = load("res://Scenes/GameOverScene.tscn").instantiate()
	game_over_scene.set_final_hope_value(hope_value)
	get_tree().root.add_child(game_over_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = game_over_scene
