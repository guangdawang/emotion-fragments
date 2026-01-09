extends Control

# 游戏结束场景脚本
# 处理游戏结束界面的逻辑

@onready var hope_value_label: Label = $HopeValue
@onready var restart_button: Button = $RestartButton
@onready var menu_button: Button = $MenuButton

const MAIN_SCENE_PATH = "res://Scenes/MainScene.tscn"
const START_SCENE_PATH = "res://Scenes/StartScene.tscn"

var final_hope_value: float = 0.0

func _ready():
	print("游戏结束场景初始化完成")
	setup_buttons()
	display_final_stats()

func setup_buttons():
	if restart_button:
		restart_button.pressed.connect(_on_restart_button_pressed)

	if menu_button:
		menu_button.pressed.connect(_on_menu_button_pressed)

func display_final_stats():
	if hope_value_label:
		hope_value_label.text = "希望值: " + str(final_hope_value)

func set_final_hope_value(value: float):
	final_hope_value = value

func _on_restart_button_pressed():
	print("重新开始游戏")
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)

func _on_menu_button_pressed():
	print("返回菜单")
	get_tree().change_scene_to_file(START_SCENE_PATH)

func _input(event):
	# 按下空格键重新开始
	if event.is_action_pressed("ui_select"):
		_on_restart_button_pressed()

	# 按下 ESC 键返回菜单
	if event.is_action_pressed("ui_cancel"):
		_on_menu_button_pressed()
