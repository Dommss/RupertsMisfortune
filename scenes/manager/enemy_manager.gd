extends Node


@export var basic_enemy_scene: PackedScene
@export var basic_enemy_two_scene: PackedScene
@export var basic_enemy_three_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var fast_enemy_scene: PackedScene
@export var fast_enemy_two_scene: PackedScene
@export var tanky_enemy_scene: PackedScene
@export var boss_enemy_scene: PackedScene
@export var arena_time_manager: Node

@onready var timer = $Timer

var spawn_radius = 500
var enemy_count: int
var scaling_enemy_count: int
var base_spawn_time = 0
var enemy_table = WeightedTable.new()
var number_to_spawn = 1


func _ready():
	enemy_table.add_item(basic_enemy_scene, 10)
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	GameEvents.enemy_died.connect(on_enemy_died)
	scaling_enemy_count = 50


func get_spawn_position():
	var player = get_tree().get_first_node_in_group("player") as Node2D
 
	if (player == null):
		return Vector2.ZERO
	
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var checks = 1
	var reducing_radius = spawn_radius
	while (true):
		var complete_turns = (checks / 4) as float
		if complete_turns > 1:
			#Reduce spawn radius by 10% each full turn
			reducing_radius = spawn_radius * (1 - (complete_turns / 10))
			spawn_position = player.global_position + (random_direction * reducing_radius)
		
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, 
			spawn_position, 1)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		if result.is_empty():
			break
		else:
			checks += 1
			random_direction = random_direction.rotated(deg_to_rad(90))
 
	print("Needed " + str(checks) + " to spawn and a radius of " + str(reducing_radius))
	return spawn_position


func on_timer_timeout():
	timer.start()
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	if enemy_count >= scaling_enemy_count:
		return
	
	for i in number_to_spawn:
		var enemy_scene = enemy_table.pick_item()
		var enemy = enemy_scene.instantiate() as Node2D
		
		var entities_layer = get_tree().get_first_node_in_group("entities_layer")
		entities_layer.add_child(enemy)
		enemy.global_position = get_spawn_position()
	
	enemy_count += number_to_spawn
	print(enemy_count)


func on_arena_difficulty_increased(arena_difficulty: int):
	var time_off = (.1 / 12) * arena_difficulty
	time_off = min(time_off, 0.9)
	timer.wait_time = base_spawn_time - time_off
	
	if arena_difficulty == 6:
		enemy_table.add_item(wizard_enemy_scene, 15)
		scaling_enemy_count = 100
	elif arena_difficulty == 18:
		enemy_table.add_item(fast_enemy_scene, 8)
		scaling_enemy_count = 150
	elif arena_difficulty == 36:
		enemy_table.add_item(basic_enemy_two_scene, 20)
		enemy_table.remove_item(basic_enemy_scene)
		scaling_enemy_count = 175
	elif arena_difficulty == 54:
		enemy_table.add_item(basic_enemy_three_scene, 20)
		enemy_table.add_item(tanky_enemy_scene, 5)
		scaling_enemy_count = 200
	elif arena_difficulty == 60:
		enemy_table.add_item(fast_enemy_two_scene, 8)
		enemy_table.remove_item(basic_enemy_two_scene)
		scaling_enemy_count = 225
	elif arena_difficulty == 84:
		enemy_table.remove_item(fast_enemy_scene)
		scaling_enemy_count = 250
	elif arena_difficulty == 120:
		enemy_table.add_item(boss_enemy_scene, 1)
	
	if (arena_difficulty % 60) == 0:
		number_to_spawn += 1


func on_enemy_died():
	enemy_count -= 1
