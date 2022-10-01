extends Node

# preload all needed entity scenes
const projectile_scene = preload("res://shooter/projectile/Projectile.tscn")
const test_enemy_scene = preload("res://shooter/test/TestEnemy.tscn")

# needed to track which nodes to buff every ten seconds
var enemies = []
var player = null

# buff type
# 1 : health
# 2 : speed
# 3 : damage
# 4 : pierce
# 5 : 

# current buffs that the enemies have
# stored in an int array
var buffs = []

# adds the entity to the main node
# so it shows up on screen
func add_node_to_root(node):
	var root = get_tree().root
	var current_scene = root.get_child(root.get_child_count() - 1)
	current_scene.add_child(node)

func add_enemy(enemy):
	enemies.append(enemy)
	
	for buff in buffs:
		add_buff_to_enemy(enemy, buff)
	
	var root = get_tree().root
	var current_scene = root.get_child(root.get_child_count() - 1)
	current_scene.add_child(enemy)

func create_enemy(type, x, y):
	var enemy = null
	if type == 0:
		enemy = test_enemy_scene.instance()
		enemy.create(x, y)
		
	if enemy != null:
		add_enemy(enemy)

func create_projectile(owner, target, speed):
	var projectile = projectile_scene.instance()
	projectile.create(owner, target, speed)
	add_node_to_root(projectile)
	
func add_buff_to_enemies(buff):
	buffs.append(buff)
	for enemy in enemies:
		add_buff_to_enemy(enemy, buff)
	
func add_buff_to_enemy(enemy, buff):
	pass
	
func process_enemies():
	for enemy in enemies:
		enemy.process_ai(player)
	
# iterates through the enemy array
# if they are !alive
# then removes them from the scene and array
func remove_dead_enemies():
	var i = 0
	while i < enemies.size():
		if !enemies[i].alive:
			enemies[i].queue_free()
			enemies.remove(i)
			i -= 1
		i += 1
