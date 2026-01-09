extends Node2D

# 碎片运动控制
# 根据当前情绪状态控制碎片的物理行为

@export var speed: float = 100.0
@export var rotation_speed: float = 1.0

var velocity: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO

# 信号
signal fragment_collided(other_fragment: Node2D)

func _ready():
	# 初始化随机速度
	velocity = Vector2(randf() - 0.5, randf() - 0.5).normalized() * speed

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
	if randf() < 0.02:  # 2%的概率改变方向
		velocity = Vector2(randf() - 0.5, randf() - 0.5).normalized() * speed * 1.5

	position += velocity * delta

	# 边界反弹
	var viewport = get_viewport_rect()
	if position.x < 0 or position.x > viewport.size.x:
		velocity.x *= -1
	if position.y < 0 or position.y > viewport.size.y:
		velocity.y *= -1

func process_refactor_motion(delta: float):
	# 向最近的碎片移动
	var nearest_fragment = find_nearest_fragment()
	if nearest_fragment:
		var direction = (nearest_fragment.position - position).normalized()
		velocity = direction * speed * 0.5
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

func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("fragments"):
		emit_signal("fragment_collided", body)
