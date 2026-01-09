extends Node

# 视觉效果管理器
# 负责处理游戏中的视觉反馈和粒子特效

@onready var particle_system: CPUParticles2D = $CPUParticles2D

# 情绪颜色配置
var emotion_colors: Dictionary = {
	0: Color(0.2, 0.4, 0.6),  # ORDER - 蓝色
	1: Color(0.8, 0.2, 0.2),  # CHAOS - 红色
	2: Color(0.2, 0.8, 0.4)   # REFACTOR - 绿色
}

# 信号
signal effect_triggered(effect_type: String, position: Vector2)

func _ready():
	print("视觉效果管理器初始化完成")
	setup_particle_system()

func setup_particle_system():
	if not particle_system:
		particle_system = CPUParticles2D.new()
		add_child(particle_system)

	particle_system.emitting = false
	particle_system.amount = 50
	particle_system.lifetime = 1.0
	particle_system.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE

func trigger_pulse_effect(position: Vector2):
	if not particle_system:
		return

	particle_system.global_position = position
	particle_system.emitting = true
	particle_system.restart()

	# 设置脉冲颜色
	var state_machine = get_node_or_null("/root/EmotionStateMachine")
	if state_machine:
		var state = state_machine.get_current_state()
		particle_system.color = emotion_colors.get(state, Color.WHITE)

	emit_signal("effect_triggered", "pulse", position)

func trigger_fragment_collision_effect(position: Vector2):
	# 创建碰撞特效
	var effect = create_collision_effect(position)
	add_child(effect)

	# 自动清理
	await get_tree().create_timer(0.5).timeout
	effect.queue_free()

func create_collision_effect(position: Vector2) -> Node:
	var effect = Node2D.new()
	effect.global_position = position

	var sprite = Sprite2D.new()
	var texture = create_collision_texture()
	sprite.texture = texture
	sprite.modulate = Color.WHITE
	sprite.scale = Vector2(0.1, 0.1)

	effect.add_child(sprite)

	# 动画效果
	var tween = create_tween()
	tween.parallel().tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.3)
	tween.parallel().tween_property(sprite, "modulate", Color.TRANSPARENT, 0.3)

	return effect

func create_collision_texture() -> Texture2D:
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# 绘制圆形
	for x in range(32):
		for y in range(32):
			var dist = Vector2(x - 16, y - 16).length()
			if dist < 16:
				var alpha = 1.0 - (dist / 16.0)
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))

	return ImageTexture.create_from_image(image)

func update_emotion_color(state: int):
	var color = emotion_colors.get(state, Color.WHITE)
	if particle_system:
		particle_system.color = color

func create_fragment_spawn_effect(position: Vector2):
	var effect = Node2D.new()
	effect.global_position = position

	var sprite = Sprite2D.new()
	var texture = create_spawn_texture()
	sprite.texture = texture
	sprite.modulate = Color.WHITE
	sprite.scale = Vector2(2.0, 2.0)

	effect.add_child(sprite)

	# 动画效果
	var tween = create_tween()
	tween.parallel().tween_property(sprite, "scale", Vector2(0.5, 0.5), 0.3)
	tween.parallel().tween_property(sprite, "modulate", Color.TRANSPARENT, 0.3)

	add_child(effect)
	await get_tree().create_timer(0.3).timeout
	effect.queue_free()

func create_spawn_texture() -> Texture2D:
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# 绘制星形
	for x in range(32):
		for y in range(32):
			var dist = Vector2(x - 16, y - 16).length()
			if dist < 16:
				var angle = Vector2(x - 16, y - 16).angle()
				var star = abs(sin(angle * 5))
				var alpha = star * (1.0 - (dist / 16.0))
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))

	return ImageTexture.create_from_image(image)
