extends Node2D

# 玩家控制器
# 处理玩家输入和移动逻辑

@export var move_speed: float = 300.0
@export var pulse_radius: float = 200.0
@export var pulse_force: float = 500.0
@export var mouse_follow_speed: float = 0.1  # 鼠标跟随平滑度

var is_pulsing: bool = false
var pulse_timer: float = 0.0
var pulse_cooldown: float = 1.0
var pulse_count: int = 0  # 脉冲使用次数统计

var target_position: Vector2 = Vector2.ZERO  # 目标位置（用于平滑移动）

# 信号
signal player_moved(new_position: Vector2)
signal pulse_activated(position: Vector2, radius: float)
signal fragment_placed(position: Vector2)

func _ready():
	print("玩家控制器初始化完成")
	add_to_group("player")
	target_position = position

func _process(delta: float):
	handle_input()
	update_pulse(delta)
	update_visuals(delta)

func handle_input():
	var movement = Vector2.ZERO

	# 键盘控制
	if Input.is_action_pressed("ui_up"):
		movement.y -= 1
	if Input.is_action_pressed("ui_down"):
		movement.y += 1
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_right"):
		movement.x += 1

	# 鼠标跟随
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = get_global_mouse_position()
		target_position = mouse_pos
		movement = (mouse_pos - position).normalized()

	# 应用移动
	if movement.length() > 0:
		movement = movement.normalized()

		# 如果是鼠标控制，使用平滑移动
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			position = position.lerp(target_position, mouse_follow_speed)
		else:
			position += movement * move_speed * get_process_delta_time()

		emit_signal("player_moved", position)

	# 脉冲技能 (空格键)
	if Input.is_action_just_pressed("ui_select") and not is_pulsing:
		activate_pulse()

	# 放置碎片 (Shift + 左键)
	if Input.is_key_pressed(KEY_SHIFT) and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		place_fragment()

func activate_pulse():
	if pulse_timer > 0:
		return

	is_pulsing = true
	pulse_timer = pulse_cooldown
	pulse_count += 1

	emit_signal("pulse_activated", position, pulse_radius)

	# 对附近的碎片施加力
	var fragments = get_tree().get_nodes_in_group("fragments")
	for fragment in fragments:
		var distance = position.distance_to(fragment.position)
		if distance < pulse_radius:
			var direction = (fragment.position - position).normalized()
			fragment.position += direction * pulse_force * 0.01

			# 如果碎片有 apply_pulse 方法，调用它
			if fragment.has_method("apply_pulse"):
				fragment.apply_pulse(1.0 - distance / pulse_radius)

	# 更新成就系统
	if AchievementSystem:
		AchievementSystem.increment_achievement_progress("pulse_master")

func update_pulse(delta: float):
	if pulse_timer > 0:
		pulse_timer -= delta
		if pulse_timer <= 0:
			is_pulsing = false

func place_fragment():
	var state_machine = get_node_or_null("/root/EmotionStateMachine")
	if state_machine and state_machine.get_current_state() == 2:  # REFACTOR
		emit_signal("fragment_placed", position)
		# 调用碎片管理器在指定位置生成碎片
		var fragment_manager = get_node_or_null("/root/FragmentManager")
		if fragment_manager:
			var fragment = fragment_manager.spawn_fragment()
			if fragment:
				fragment.position = position
				# 增加希望值
				if GameManager:
					GameManager.add_hope(5.0)

				# 更新成就系统
				if AchievementSystem:
					AchievementSystem.increment_achievement_progress("fragment_collector")

func update_visuals(delta: float):
	queue_redraw()

func _draw():
	# 绘制玩家指示器
	var player_color = Color.WHITE
	if is_pulsing:
		player_color = Color.CYAN

	draw_circle(Vector2.ZERO, 10, player_color)

	# 绘制脉冲范围
	if is_pulsing:
		var alpha = pulse_timer / pulse_cooldown
		var pulse_color = Color(1, 1, 1, alpha)
		draw_arc(Vector2.ZERO, pulse_radius, 0, TAU, 32, pulse_color, 2.0)
		draw_circle(Vector2.ZERO, pulse_radius, Color(1, 1, 1, alpha * 0.1))
