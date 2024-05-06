extends CharacterBody2D

@export var base_speed : int
@export var jets : Array
@export var length : String

@export var mass : float

@export var delay_shoot : bool
var delay_shoot_index = 1
var gun_timer = 0
@export var GUNDELAY = 0.6

@export var MaxHealth : float
@export var health : float
@export var rotspeed : float
@export var blast_scene : PackedScene
@export var blast_points : Array
@export var turrets : Array

@onready var mroot = get_tree().get_root().get_node("Game")

var second_shotted = false



@onready var camera = $Camera2D



var rotvel = 0

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	camera.make_current()

func rotate_towards_target(object_to_rotate, target, rotation_speed):
	var target_angle = object_to_rotate.global_position.angle_to_point(target)
	object_to_rotate.rotation = lerp_angle(object_to_rotate.rotation, target_angle, rotation_speed)

func _physics_process(delta):
	if not is_multiplayer_authority():
		#update_physical_healthbar()
		return
	
	for turret in turrets:
		var turt = get_node(turret)
		var old_rot = turt.rotation
		get_node(turret).look_at(get_global_mouse_position())
		var new_rot = turt.rotation
		turt.rotation = lerp_angle(old_rot, new_rot, turt.rot_speed)
		#print(get_node(turret).global_position)
	
	update_healthbar()

	gun_timer -= delta 
	if Input.is_action_pressed("fire"):
		if gun_timer < 0:
			gun_timer = GUNDELAY
			if delay_shoot:
				delay_shoot_index += 1
				delay_shoot_index = delay_shoot_index%len(blast_points)
				shoot.rpc(get_node(blast_points[delay_shoot_index]).global_rotation, get_node(blast_points[delay_shoot_index]).global_position, 1800, z_index, velocity)
			else:
				for bpoint in blast_points:
					shoot.rpc(get_node(bpoint).global_rotation, get_node(bpoint).global_position, 1800, z_index, velocity)

	var thrust = Input.get_axis("brake", "thrust")

	if not thrust:
		thrust = 0.3
	velocity += -transform.y * (thrust+1) * delta * base_speed
	
	for jetpointparticle in jets:
		get_node(jetpointparticle).initial_velocity_max = thrust*250

	if thrust > 0:
		velocity *= 0.99 # diffuse vel

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		rotvel += direction*(rotspeed*3)

	rotvel *= (0.90+(mass/1010))

	rotation += rotvel/100*delta

	move_and_slide()

func die(reason):
	pass

func menu_toggle():
	pass

@rpc("call_local")
func shoot(rot, gpos, speed, zdex, vel):
	var instance = blast_scene.instantiate()
	instance.dir = rot
	instance.spawnPos = gpos
	instance.spawnRot = rot
	instance.speed = speed
	instance.zindex = zdex+1
	instance.vel = vel
	instance.host_name = name
	mroot.add_child(instance)

@rpc("any_peer")
func recieve_damage(amount):
	health -= amount
	if health < 1:
		health = MaxHealth
		position = Vector2.ZERO

@rpc("call_local")
func update_healthbar():
	var UIHealth = get_tree().get_root().get_node("Game/UI/Health")
	UIHealth.value = health/MaxHealth*100


#func update_physical_healthbar():
	#overheadhealth.value = int(health/MaxHealth*100)
