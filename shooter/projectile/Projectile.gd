extends Area2D

var velocity = Vector2.ZERO
var start_position = Vector2.ZERO
var distance = Vector2.ZERO
var damage = 0
var pierce = 0
var dot = 0
var explode = 0
var explode_type = 0
var shielding = false
var hit_targets = []

func create(owner, target, speed, accuracy, distance, damage, pierce, dot, explode, explode_type, shielding):
	position = owner.position
	start_position = position
	
	look_at(target)
	rotation_degrees += 90.0
	
	self.collision_layer = owner.collision_layer
	self.collision_mask = owner.collision_mask
	
	# find the direction the bullet should shoot
	# add some randomoness if necessary
	var theta = atan2(target.y - position.y, target.x - position.x)
	theta = rad2deg(theta)
	var rng = 360 - (360 * accuracy)
	var inaccuracy = randf() * rng - (rng * 0.5)
	theta += inaccuracy
	theta = deg2rad(theta)
	
	velocity.x = cos(theta) * speed
	velocity.y = sin(theta) * speed
	
	self.distance = distance
	self.damage = damage
	self.pierce = pierce
	self.dot = dot
	self.explode = explode
	self.explode_type = explode_type
	self.shielding = shielding
	
	if shielding:
		$Sprite.play("shield")
		scale = Vector2(4, 4)
	elif owner.is_in_group("Player"):
		if explode > 0:
			$Sprite.play("shock")
			scale = Vector2(3, 3)
		else:
			$Sprite.play("player_bullet")
			scale = Vector2(1, 1)
	elif owner.is_in_group("ChemThrower"):
		$Sprite.play("slime")
		scale = Vector2(3, 3)
	elif owner.is_in_group("Drone"):
		$Sprite.play("close_shock")
		scale = Vector2(4, 4)
	elif owner.is_in_group("SpiderBoss"):
		if explode > 0:
			$Sprite.play("normal_explode")
			scale = Vector2(3, 3)
		else:
			$Sprite.play("default")
			scale = Vector2(1, 1)
	else:
		$Sprite.play("default")
		scale = Vector2(1, 1)
	$Sprite.frame = 0
	
	hit_targets.clear()
	
	# what sound to play
	if owner.is_in_group("Player"):
		if explode > 0:
			SoundManager.play_sound("player-grenade")
		elif shielding:
			SoundManager.play_sound("player-melee")
		else:
			SoundManager.play_sound("player-shot")
	elif owner.is_in_group("Drone"):
		SoundManager.play_sound("drone-shot")
	elif owner.is_in_group("ChemThrower"):
		SoundManager.play_sound("chem-thrower-shot")
	else:
		SoundManager.play_sound("soldier-shot")

func _physics_process(delta):
	position += velocity * delta
	
func _process(delta):
	if position.distance_to(start_position) >= distance:
		if explode > 0:
			EntityManager.create_explosion(self, damage, explode, dot, explode_type)
		damage = 0
		queue_free()

func _on_Projectile_body_entered(body):	
	if body.is_in_group("Mob"):
		for hit in hit_targets:
			if hit == body:
				return
		
		body.take_damage(damage)
		if dot > 0:
			body.add_dot(dot)
		
		if pierce > 1:
			hit_targets.append(body)
			pierce -= 1
		else:
			if explode > 0:
				EntityManager.create_explosion(self, damage, explode, dot, explode_type)
			damage = 0
			queue_free()
	elif !shielding:
		if explode:
			EntityManager.create_explosion(self, damage, explode, dot, explode_type)
		damage = 0
		queue_free()

func _on_Projectile_area_entered(area):
	if shielding && area.is_in_group("Projectile"):
		area.queue_free()
	elif area.is_in_group("Crate"):
		if pierce > 1:
			pierce -= 1
		else:
			damage = 0
			queue_free()
