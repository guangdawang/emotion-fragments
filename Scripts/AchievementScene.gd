extends Control

# 成就显示场景脚本
# 处理成就列表的显示和交互

@onready var achievement_list: VBoxContainer = $AchievementList/VBoxContainer
@onready var back_button: Button = $BackButton

const START_SCENE_PATH = "res://Scenes/StartScene.tscn"

func _ready():
	print("成就场景初始化完成")
	setup_buttons()
	display_achievements()

func setup_buttons():
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)

func display_achievements():
	if not achievement_list:
		return

	# 清空现有列表
	for child in achievement_list.get_children():
		child.queue_free()

	# 获取所有成就
	var achievements = AchievementSystem.get_all_achievements()

	# 显示每个成就
	for achievement_id in achievements:
		var achievement = achievements[achievement_id]
		create_achievement_entry(achievement)

func create_achievement_entry(achievement: Dictionary):
	# 创建成就条目
	var container = HBoxContainer.new()
	container.custom_minimum_size = Vector2(0, 60)

	# 创建成就图标
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(50, 50)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL

	# 根据解锁状态设置图标颜色
	if achievement["unlocked"]:
		icon.modulate = Color.GOLD
	else:
		icon.modulate = Color.GRAY

	container.add_child(icon)

	# 创建成就信息容器
	var info_container = VBoxContainer.new()
	info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# 创建成就名称
	var name_label = Label.new()
	name_label.text = achievement["name"]
	name_label.add_theme_font_size_override("font_size", 16)

	if achievement["unlocked"]:
		name_label.add_theme_color_override("font_color", Color.GOLD)
	else:
		name_label.add_theme_color_override("font_color", Color.GRAY)

	info_container.add_child(name_label)

	# 创建成就描述
	var desc_label = Label.new()
	desc_label.text = achievement["description"]
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)

	info_container.add_child(desc_label)

	# 如果有进度，显示进度
	if "progress" in achievement and "target" in achievement:
		var progress_label = Label.new()
		progress_label.text = "进度: %d/%d" % [achievement["progress"], achievement["target"]]
		progress_label.add_theme_font_size_override("font_size", 10)
		progress_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)

		info_container.add_child(progress_label)

	container.add_child(info_container)
	achievement_list.add_child(container)

func _on_back_button_pressed():
	print("返回菜单")
	get_tree().change_scene_to_file(START_SCENE_PATH)

func _input(event):
	# 按下 ESC 键返回菜单
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()
