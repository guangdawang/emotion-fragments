extends Node

# 情绪状态机
# 负责管理游戏的不同情绪阶段及其转换逻辑

enum EmotionState {
	ORDER,      # 秩序/压抑
	CHAOS,      # 混乱/焦虑
	REFACTOR    # 重构/希望
}

# 当前状态
var current_state: EmotionState = EmotionState.ORDER

# 状态转换阈值
const CHAOS_THRESHOLD: float = 50.0
const REFACTOR_THRESHOLD: float = 70.0

# 信号
signal state_entered(state: EmotionState)
signal state_exited(state: EmotionState)

func _ready():
	print("情绪状态机初始化完成")
	emit_signal("state_entered", current_state)

func transition_to(new_state: EmotionState) -> bool:
	if current_state == new_state:
		return false

	emit_signal("state_exited", current_state)
	current_state = new_state
	emit_signal("state_entered", current_state)

	print("状态转换: ", EmotionState.keys()[current_state])
	return true

func get_current_state() -> EmotionState:
	return current_state

func get_state_name() -> String:
	return EmotionState.keys()[current_state]

# 检查是否应该转换到混乱状态
func should_transition_to_chaos(hope_value: float) -> bool:
	return current_state == EmotionState.ORDER and hope_value >= CHAOS_THRESHOLD

# 检查是否应该转换到重构状态
func should_transition_to_refactor(anxiety_value: float, control_value: float) -> bool:
	return current_state == EmotionState.CHAOS and anxiety_value >= REFACTOR_THRESHOLD and control_value >= REFACTOR_THRESHOLD
