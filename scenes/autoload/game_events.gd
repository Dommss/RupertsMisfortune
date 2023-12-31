extends Node

signal experience_ectoplasm_collected(number: float)
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
signal player_damaged
signal enemy_died

func emit_ectoplasm_exp_collected(number: float):
	experience_ectoplasm_collected.emit(number)


func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade, current_upgrades)


func emit_player_damaged():
	player_damaged.emit()


func emit_enemy_died():
	enemy_died.emit()
