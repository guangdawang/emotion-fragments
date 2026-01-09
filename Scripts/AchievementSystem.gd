extends Node

# 成就系统
# 管理游戏中的成就解锁和进度

signal achievement_unlocked(achievement_id: String)

# 成就定义
var achievements: Dictionary = {
	"first_fragment": {
		"id": "first_fragment",
		"name": "初次接触",
		"description": "第一次与碎片互动",
		"unlocked": false
	},
	"chaos_master": {
		"id": "chaos_master",
		"name": "混乱大师",
		"description": "在混乱阶段保持控制力超过80",
		"unlocked": false
	},
	"hope_bearer": {
		"id": "hope_bearer",
		"name": "希望的使者",
		"description": "希望值达到100",
		"unlocked": false
	},
	"refactor_expert": {
		"id": "refactor_expert",
		"name": "重构专家",
		"description": "成功完成重构阶段",
		"unlocked": false
	},
	"pulse_master": {
		"id": "pulse_master",
		"name": "脉冲大师",
		"description": "使用脉冲技能50次",
		"unlocked": false,
		"progress": 0,
		"target": 50
	},
	"fragment_collector": {
		"id": "fragment_collector",
		"name": "碎片收集者",
		"description": "放置100个碎片",
		"unlocked": false,
		"progress": 0,
		"target": 100
	},
	"order_keeper": {
		"id": "order_keeper",
		"name": "秩序守护者",
		"description": "在秩序阶段保持希望值超过50",
		"unlocked": false
	},
	"speed_runner": {
		"id": "speed_runner",
		"name": "速通大师",
		"description": "在60秒内完成游戏",
		"unlocked": false
	},
	"perfectionist": {
		"id": "perfectionist",
		"name": "完美主义者",
		"description": "以希望值100完成游戏",
		"unlocked": false
	}
}

func _ready():
	print("成就系统初始化完成")

func unlock_achievement(achievement_id: String):
	if achievement_id in achievements:
		var achievement = achievements[achievement_id]
		if not achievement["unlocked"]:
			achievement["unlocked"] = true
			emit_signal("achievement_unlocked", achievement_id)
			print("成就解锁: ", achievement["name"])

func update_achievement_progress(achievement_id: String, progress: int):
	if achievement_id in achievements:
		var achievement = achievements[achievement_id]
		if "progress" in achievement and "target" in achievement:
			achievement["progress"] = progress
			if achievement["progress"] >= achievement["target"]:
				unlock_achievement(achievement_id)

func increment_achievement_progress(achievement_id: String, amount: int = 1):
	if achievement_id in achievements:
		var achievement = achievements[achievement_id]
		if "progress" in achievement and "target" in achievement:
			var new_progress = achievement.get("progress", 0) + amount
			update_achievement_progress(achievement_id, new_progress)

func is_achievement_unlocked(achievement_id: String) -> bool:
	if achievement_id in achievements:
		return achievements[achievement_id]["unlocked"]
	return false

func get_achievement_info(achievement_id: String) -> Dictionary:
	if achievement_id in achievements:
		return achievements[achievement_id]
	return {}

func get_all_achievements() -> Dictionary:
	return achievements

func reset_achievements():
	for achievement_id in achievements:
		achievements[achievement_id]["unlocked"] = false
		if "progress" in achievements[achievement_id]:
			achievements[achievement_id]["progress"] = 0
	print("成就已重置")
