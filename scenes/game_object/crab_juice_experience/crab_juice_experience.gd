extends Node2D


func _ready():
	$Area2D.area_entered.connect(on_area_entered)
	

func on_area_entered(other_area: Area2D):
	GameEvents.emit_crab_juice_exp_collected(1)
	queue_free()