extends Control

# 启动场景脚本
# 处理游戏启动界面的逻辑

@onready var start_button: Button = $StartButton
@onready var tutorial_button: Button = $TutorialButton
@onready var achievement_button: Button = $AchievementButton
@onready var quit_button: Button = $QuitButton

const MAIN_SCENE_PATH = "res://Scenes/MainScene.tscn"
const TUTORIAL_SCENE_PATH = "res://Scenes/TutorialScene.tscn"
const ACHIEVEMENT_SCENE_PATH = "res://Scenes/AchievementScene.tscn"

func _ready():
	print("启动场景初始化完成")
	setup_buttons()

func setup_buttons():
	# 设置按钮样式
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)

	if tutorial_button:
		tutorial_button.pressed.connect(_on_tutorial_button_pressed)

	if achievement_button:
		achievement_button.pressed.connect(_on_achievement_button_pressed)

	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed():
	print("开始游戏")
	# 加载主场景
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)

func _on_tutorial_button_pressed():
	print("打开教程")
	# 加载教程场景
	get_tree().change_scene_to_file(TUTORIAL_SCENE_PATH)

func _on_achievement_button_pressed():
	print("打开成就列表")
	# 加载成就场景
	get_tree().change_scene_to_file(ACHIEVEMENT_SCENE_PATH)

func _on_quit_button_pressed():
	print("退出游戏")
	get_tree().quit()

func _input(event):
	# 按下空格键开始游戏
	if event.is_action_pressed("ui_select"):
		_on_start_button_pressed()

	# 按下 ESC 键退出游戏
	if event.is_action_pressed("ui_cancel"):
		_on_quit_button_pressed()
