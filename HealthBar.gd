extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

@onready var HealthBar = $"../Health"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if value > HealthBar.value:
		value = ((HealthBar.value-value)/5-1)+value
	else:
		value = HealthBar.value



