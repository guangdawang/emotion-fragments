extends Node

# 碎片管理器
# 负责碎片的生成、回收和对象池管理

const MAX_FRAGMENTS: int = 500
const FRAGMENT_SCENE: PackedScene = preload("res://Scenes/Fragment.tscn")

# 对象池
var fragment_pool: Array[Node2D] = []
var active_fragments: Array[Node2D] = []

# 生成配置
var spawn_rate: float = 1.0
var spawn_timer: float = 0.0

# 情绪状态相关的生成参数
var order_spawn_interval: float = 2.0  # 秩序阶段生成间隔
var chaos_spawn_interval: float = 0.5  # 混乱阶段生成间隔
var refactor_spawn_interval: float = 1.0  # 重构阶段生成间隔

# 信号
signal fragment_created(fragment: Node2D)
signal fragment_destroyed(fragment: Node2D)

func _ready():
	print("碎片管理器初始化完成")
	# 预创建对象池
	initialize_pool()

func initialize_pool():
	for i in range(MAX_FRAGMENTS):
		var fragment = FRAGMENT_SCENE.instantiate()
		fragment.visible = false
		add_child(fragment)
		fragment_pool.append(fragment)
	print("对象池初始化完成，共 ", fragment_pool.size(), " 个碎片")

func _process(delta: float):
	# 根据当前情绪状态调整生成速率
	update_spawn_rate()

	spawn_timer += delta * spawn_rate
	if spawn_timer >= 1.0:
		spawn_timer = 0.0
		if active_fragments.size() < MAX_FRAGMENTS:
			spawn_fragment()

func update_spawn_rate():
	var state_machine = get_node_or_null("/root/EmotionStateMachine")
	if not state_machine:
		spawn_rate = 1.0
		return

	var state = state_machine.get_current_state()
	match state:
		0: # ORDER
			spawn_rate = 1.0 / order_spawn_interval
		1: # CHAOS
			spawn_rate = 1.0 / chaos_spawn_interval
		2: # REFACTOR
			spawn_rate = 1.0 / refactor_spawn_interval

func spawn_fragment() -> Node2D:
	if fragment_pool.is_empty():
		return null

	var fragment = fragment_pool.pop_back()
	fragment.visible = true
	fragment.set_process(true)

	# 根据当前情绪状态设置初始位置和行为
	setup_fragment_behavior(fragment)

	active_fragments.append(fragment)
	emit_signal("fragment_created", fragment)
	return fragment

func recycle_fragment(fragment: Node2D):
	if fragment in active_fragments:
		fragment.visible = false
		fragment.set_process(false)
		active_fragments.erase(fragment)
		fragment_pool.append(fragment)
		emit_signal("fragment_destroyed", fragment)

func setup_fragment_behavior(fragment: Node2D):
	# 根据当前情绪状态设置碎片行为
	var state_machine = get_node_or_null("/root/EmotionStateMachine")
	if state_machine:
		var state = state_machine.get_current_state()
		match state:
			0: # ORDER
				# 秩序阶段：规则排列
				fragment.position = get_ordered_position()
				if fragment.has_method("set_target_position"):
					fragment.set_target_position(get_ordered_position())
			1: # CHAOS
				# 混乱阶段：随机位置
				fragment.position = get_random_position()
			2: # REFACTOR
				# 重构阶段：相互吸引
				fragment.position = get_random_position()

func get_ordered_position() -> Vector2:
	var viewport = get_viewport().get_visible_rect()
	var grid_size = 50
	var x = (randi() % int(viewport.size.x / grid_size)) * grid_size
	var y = (randi() % int(viewport.size.y / grid_size)) * grid_size
	return Vector2(x, y)

func get_random_position() -> Vector2:
	var viewport = get_viewport().get_visible_rect()
	return Vector2(
		randf() * viewport.size.x,
		randf() * viewport.size.y
	)

func clear_all_fragments():
	for fragment in active_fragments:
		recycle_fragment(fragment)

func get_active_fragment_count() -> int:
	return active_fragments.size()

func get_pooled_fragment_count() -> int:
	return fragment_pool.size()
