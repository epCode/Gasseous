extends CharacterBody2D

@export var speed : float
@export var Damage : int

var dir : float
var spawnPos : Vector2
var spawnRot : float
var zindex : int
var vel : Vector2

var host_name : String

func _ready():
	global_position = spawnPos
	global_rotation = spawnRot
	z_index = zindex
	velocity = vel

var _timer = 4

func _physics_process(delta):
	_timer -= delta
	velocity = Vector2(0,-speed).rotated(dir)+vel
	move_and_slide()
	if _timer < 0:
		queue_free()

@onready var small_explosion = preload("res://blasts/small_explosion.tscn")
@onready var mroot = get_tree().get_root().get_node("Game")



func _on_area_2d_area_entered(area):
	if area.name != "playerea" or area.get_parent().name == host_name:
		return
	area.get_parent().velocity += velocity/20/area.get_parent().mass
	area.get_parent().rotvel += randf_range(-100,100)/area.get_parent().mass
	
	area.get_parent().recieve_damage.rpc_id(area.get_parent().get_multiplayer_authority(), Damage)
	
	var expl = small_explosion.instantiate()
	expl.pos = global_position
	expl.rot = rotation
	expl.vel = velocity
	mroot.add_child(expl)
	queue_free()
