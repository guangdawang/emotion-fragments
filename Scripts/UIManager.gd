extends CanvasLayer

# UI 管理器
# 负责处理游戏中的用户界面显示和交互

@onready var hope_bar: ProgressBar = $HopeBar
@onready var anxiety_bar: ProgressBar = $AnxietyBar
@onready var control_bar: ProgressBar = $ControlBar
@onready var state_label: Label = $StateLabel
@onready var pause_menu: Control = $PauseMenu

# 引用游戏管理器
var game_manager: Node2D

func _ready():
	print("UI 管理器初始化完成")
	setup_ui()
	connect_signals()

func setup_ui():
	# 初始化UI元素
	if hope_bar:
		hope_bar.min_value = 0.0
		hope_bar.max_value = 100.0
		hope_bar.value = 0.0

	if anxiety_bar:
		anxiety_bar.min_value = 0.0
		anxiety_bar.max_value = 100.0
		anxiety_bar.value = 0.0

	if control_bar:
		control_bar.min_value = 0.0
		control_bar.max_value = 100.0
		control_bar.value = 0.0

	if pause_menu:
		pause_menu.visible = false

func connect_signals():
	# 连接游戏管理器的信号
	game_manager = get_node_or_null("/root/Main")
	if game_manager:
		game_manager.hope_changed.connect(_on_hope_changed)
		game_manager.anxiety_changed.connect(_on_anxiety_changed)
		game_manager.control_changed.connect(_on_control_changed)
		game_manager.state_changed.connect(_on_state_changed)
		game_manager.game_paused.connect(_on_game_paused)
		game_manager.game_resumed.connect(_on_game_resumed)

func _on_hope_changed(value: float):
	if hope_bar:
		hope_bar.value = value

func _on_anxiety_changed(value: float):
	if anxiety_bar:
		anxiety_bar.value = value

func _on_control_changed(value: float):
	if control_bar:
		control_bar.value = value

func _on_state_changed(new_state):
	if state_label:
		var state_name = GameManager.EmotionState.keys()[new_state]
		state_label.text = "当前状态: " + state_name

func _on_game_paused():
	if pause_menu:
		pause_menu.visible = true

func _on_game_resumed():
	if pause_menu:
		pause_menu.visible = false

func _on_resume_button_pressed():
	if game_manager:
		game_manager.resume_game()

func _on_quit_button_pressed():
	if game_manager:
		game_manager.end_game()
