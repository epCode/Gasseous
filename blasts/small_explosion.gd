extends CharacterBody2D

var pos : Vector2
var rot : float
var vel : Vector2

@onready var partic = $CPUParticles2D
@onready var partic2 = $CPUParticles2D2
# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = pos
	rotation = rot
	velocity = vel
# Called every frame. 'delta' is the elapsed time since the previous frame.

