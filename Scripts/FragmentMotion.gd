extends Node2D

# 碎片运动控制
# 根据当前情绪状态控制碎片的物理行为

@export var speed: float = 100.0
@export var rotation_speed: float = 1.0
@export var attraction_force: float = 50.0  # 吸引力强度

var velocity: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var base_color: Color = Color.WHITE
var pulse_effect: float = 0.0  # 脉冲效果强度

# 信号
signal fragment_collided(other_fragment: Node2D)

func _ready():
	# 初始化随机速度
	velocity = Vector2(randf() - 0.5, randf() - 0.5).normalized() * speed
	# 初始化随机颜色
	base_color = Color.from_hsv(randf(), 0.8, 0.9)

func _process(delta: float):
	var state_machine = get_node_or_null("/root/EmotionStateMachine")
	if not state_machine:
		return

	var state = state_machine.get_current_state()

	match state:
		0: # ORDER - 规则运动
			process_ordered_motion(delta)
		1: # CHAOS - 混乱运动
			process_chaos_motion(delta)
		2: # REFACTOR - 相互吸引
			process_refactor_motion(delta)

	# 应用旋转
	rotation += rotation_speed * delta

	# 应用脉冲效果衰减
	if pulse_effect > 0:
		pulse_effect = max(0, pulse_effect - delta * 2.0)
		update_visuals()

func process_ordered_motion(delta: float):
	# 移动向目标位置
	var direction = (target_position - position).normalized()
	if direction.length() > 0.1:
		velocity = direction * speed
		position += velocity * delta
	else:
		velocity = Vector2.ZERO

func process_chaos_motion(delta: float):
	# 布朗运动 - 随机改变方向
	if randf() < 0.03:  # 3%的概率改变方向
		velocity = Vector2(randf() - 0.5, randf() - 0.5).normalized() * speed * 1.5

	position += velocity * delta

	# 边界反弹
	var viewport = get_viewport_rect()
	if position.x < 0 or position.x > viewport.size.x:
		velocity.x *= -1
		position.x = clamp(position.x, 0, viewport.size.x)
	if position.y < 0 or position.y > viewport.size.y:
		velocity.y *= -1
		position.y = clamp(position.y, 0, viewport.size.y)

func process_refactor_motion(delta: float):
	# 向最近的碎片移动
	var nearest_fragment = find_nearest_fragment()
	if nearest_fragment:
		var direction = (nearest_fragment.position - position).normalized()
		var distance = position.distance_to(nearest_fragment.position)

		# 距离越近，吸引力越强
		var force = attraction_force / (distance + 1)
		velocity = direction * speed * 0.5 + direction * force * delta
		position += velocity * delta

func find_nearest_fragment() -> Node2D:
	var fragments = get_tree().get_nodes_in_group("fragments")
	var nearest: Node2D = null
	var min_distance = INF

	for fragment in fragments:
		if fragment == self:
			continue
		var distance = position.distance_to(fragment.position)
		if distance < min_distance:
			min_distance = distance
			nearest = fragment

	return nearest

func set_target_position(pos: Vector2):
	target_position = pos

func apply_pulse(force: float):
	pulse_effect = min(1.0, pulse_effect + force)
	update_visuals()

func update_visuals():
	# 更新碎片视觉效果
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		var scale_factor = 1.0 + pulse_effect * 0.5
		sprite.scale = Vector2(scale_factor, scale_factor)
		sprite.modulate = base_color.lerp(Color.WHITE, pulse_effect * 0.3)

func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("fragments"):
		emit_signal("fragment_collided", body)

		# 检查成就系统
		if AchievementSystem:
			AchievementSystem.unlock_achievement("first_fragment")
