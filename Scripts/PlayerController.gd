extends Node2D

# 玩家控制器
# 处理玩家输入和移动逻辑

@export var move_speed: float = 300.0
@export var pulse_radius: float = 200.0
@export var pulse_force: float = 500.0

var is_pulsing: bool = false
var pulse_timer: float = 0.0
var pulse_cooldown: float = 1.0

# 信号
signal player_moved(new_position: Vector2)
signal pulse_activated(position: Vector2, radius: float)
signal fragment_placed(position: Vector2)

func _ready():
	print("玩家控制器初始化完成")
	add_to_group("player")

func _process(delta: float):
	handle_input()
	update_pulse(delta)

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
		movement = (mouse_pos - position).normalized()

	# 应用移动
	if movement.length() > 0:
		movement = movement.normalized()
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
	emit_signal("pulse_activated", position, pulse_radius)

	# 对附近的碎片施加力
	var fragments = get_tree().get_nodes_in_group("fragments")
	for fragment in fragments:
		var distance = position.distance_to(fragment.position)
		if distance < pulse_radius:
			var direction = (fragment.position - position).normalized()
			fragment.position += direction * pulse_force * 0.01

func update_pulse(delta: float):
	if pulse_timer > 0:
		pulse_timer -= delta
		if pulse_timer <= 0:
			is_pulsing = false

func place_fragment():
	var state_machine = get_node_or_null("/root/EmotionStateMachine")
	if state_machine and state_machine.get_current_state() == 2:  # REFACTOR
		emit_signal("fragment_placed", position)
		# 这里可以调用碎片管理器在指定位置生成碎片
		var fragment_manager = get_node_or_null("/root/FragmentManager")
		if fragment_manager:
			var fragment = fragment_manager.spawn_fragment()
			if fragment:
				fragment.position = position

func _draw():
	# 绘制玩家指示器
	draw_circle(Vector2.ZERO, 10, Color.WHITE)

	# 绘制脉冲范围
	if is_pulsing:
		draw_arc(Vector2.ZERO, pulse_radius, 0, TAU, 32, Color.WHITE, 2.0)
