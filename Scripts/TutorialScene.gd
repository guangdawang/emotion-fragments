extends Control

# 教程场景脚本
# 处理游戏教程界面的逻辑

@onready var back_button: Button = $BackButton

const START_SCENE_PATH = "res://Scenes/StartScene.tscn"

func _ready():
	print("教程场景初始化完成")
	setup_buttons()

func setup_buttons():
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed():
	print("返回菜单")
	get_tree().change_scene_to_file(START_SCENE_PATH)

func _input(event):
	# 按下 ESC 键返回菜单
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()
