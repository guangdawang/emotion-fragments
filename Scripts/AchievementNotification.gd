extends CanvasLayer

# 成就通知系统
# 在游戏中显示成就解锁提示

@onready var notification_container: VBoxContainer = $NotificationContainer
@onready var notification_template: Control = $NotificationTemplate

const NOTIFICATION_DURATION: float = 3.0  # 通知显示时长（秒）

func _ready():
	print("成就通知系统初始化完成")
	notification_template.visible = false

	# 连接成就系统信号
	if AchievementSystem:
		AchievementSystem.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(achievement_id: String):
	print("成就解锁: ", achievement_id)

	# 获取成就信息
	var achievement = AchievementSystem.get_achievement_info(achievement_id)
	if achievement.is_empty():
		return

	# 创建通知
	create_notification(achievement)

func create_notification(achievement: Dictionary):
	# 创建通知容器
	var notification = notification_template.duplicate()
	notification.visible = true

	# 设置成就名称
	if notification.has_node("NameLabel"):
		var name_label = notification.get_node("NameLabel")
		name_label.text = achievement["name"]

	# 设置成就描述
	if notification.has_node("DescLabel"):
		var desc_label = notification.get_node("DescLabel")
		desc_label.text = achievement["description"]

	# 添加到通知容器
	notification_container.add_child(notification)

	# 创建计时器，自动移除通知
	var timer = get_tree().create_timer(NOTIFICATION_DURATION)
	timer.timeout.connect(_remove_notification.bind(notification))

func _remove_notification(notification: Control):
	if notification and notification.is_inside_tree():
		notification.queue_free()
