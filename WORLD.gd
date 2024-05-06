extends Node2D

@onready var local_player = $"."
var in_game = false

@onready var mainmenu = $CANVAS/MainMenu2
@onready var address_entry = $CANVAS/MainMenu2/MarginContainer/VBoxContainer/EnterAddress
@onready var chat_entry = $CANVAS/PauseMenu/MarginContainer/VBoxContainer/Chat
@onready var pause_menu = $CANVAS/PauseMenu


@onready var ship_choose_menu = $CANVAS/ShipMenu
@onready var ship_choose_display = $CANVAS/ShipMenu/MarginContainer/HBoxContainer/VBoxContainer3/shipmenuDisplay
const PORT = 8901
var enet_peer = ENetMultiplayerPeer.new()
# Called when the node enters the scene tree for the first time.

var FACTION = "empire"
var factions = [
	"rebels",
	"empire",
]


@onready var ships = {
	"rebels": [
		[[preload("res://Player/xwing.tscn"), "X-Wing"], load("res://TEXTURES/TEXTURES/player/x-wing.png")],
		[[preload("res://Player/tantive.tscn"), "CR-90 Corvette"], load("res://TEXTURES/TEXTURES/player/Tantive.png")]
	],
	"empire": [
		[[preload("res://Player/tiefighter.tscn"), "Tie-Fighter"], load("res://TEXTURES/TEXTURES/player/tie-fighter.png")],
		[[preload("res://Player/stardestroyer.tscn"), "Star Destroyer"], load("res://TEXTURES/TEXTURES/player/stardestroyer.png")]
	],
}


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_host_pressed():
	main_menu(false)
	
	ship_menu(true)
	
	enet_peer.create_server(PORT)
	
	#multiplayer.peer_connected.connect(add_client_player)

	multiplayer.multiplayer_peer = enet_peer
	#add_player(multiplayer.get_unique_id())

@onready var shipmenuDisplay = $CANVAS/ShipMenu/MarginContainer/HBoxContainer/VBoxContainer3/shipmenuDisplay
@onready var backround = $CANVAS/BACKROUND

func ship_menu(boo):
	if boo:
		backround.show()
		ship_choose_menu.show()
		shipmenuDisplay.show()
	else:
		backround.hide()
		ship_choose_menu.hide()
		shipmenuDisplay.hide()
func main_menu(boo):
	if boo:
		backround.show()
		mainmenu.show()
	else:
		backround.hide()
		mainmenu.hide()

func _on_join_pressed():
	main_menu(false)
	ship_menu(true)
	var ADDRESS = "localhost"
	if address_entry.text != "":
		ADDRESS = address_entry.text
	
	enet_peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = enet_peer
	

@rpc("any_peer")
func add_player(peer_id, faction, index):
	var player = ships[faction][index][0][0].instantiate()
	player.name = str(peer_id)
	add_child(player)
	return player
	
	

func _physics_process(delta):
	if Input.is_action_just_pressed("pause_menu") and in_game:
		if pause_menu.is_visible_in_tree():
			pause_menu.hide()
		else:
			pause_menu.show()


func _on_quit_pressed():
	get_tree().quit()


func _on_spectate_pressed():
	pass

@onready var UI = $UI
@onready var factionChoice = $CANVAS/ShipMenu/MarginContainer/HBoxContainer/VBoxContainer2/FactionSelect

func _on_join_game_pressed():
	UI.show()
	ship_menu(false)
	in_game = true
	var index = 1
	if UIShipChoice.get_selected_items()[0] != -1:
		index = UIShipChoice.get_selected_items()[0]
	if multiplayer.get_unique_id() == 1:
		add_player(multiplayer.get_unique_id(), FACTION, index)
		return
	rpc_id(1, "add_player", multiplayer.get_unique_id(), FACTION, index)


@onready var defaultshipselecttexture = load("res://TEXTURES/TEXTURES/player/ship_choose_temp.png")

@onready var LengthText = $CANVAS/ShipMenu/MarginContainer/HBoxContainer/VBoxContainer3/Length
@onready var SpeedText = $CANVAS/ShipMenu/MarginContainer/HBoxContainer/VBoxContainer3/Speed
@onready var FireRateText = $"CANVAS/ShipMenu/MarginContainer/HBoxContainer/VBoxContainer3/Fire Rate"
@onready var ClassText = $CANVAS/ShipMenu/MarginContainer/HBoxContainer/VBoxContainer3/Class

func _on_ship_selected_or_ship_moused_over(index):
	var temp_ship = ships[FACTION][index][0][0].instantiate()
	
	LengthText.text = "Length: "+""
	SpeedText = "Speed: "
	FireRateText.text = "Fire Rate: "+str(int(1/temp_ship.GUNDELAY))
	ClassText = "Class: "
	
	if index == -1:
		print("s")
		ship_choose_display.texture = defaultshipselecttexture
	else:
		ship_choose_display.texture = ships[FACTION][index][1]

@onready var UIJoinGame = $CANVAS/ShipMenu/MarginContainer/HBoxContainer/VBoxContainer/JoinGame
@onready var UIShipChoice = $CANVAS/ShipMenu/MarginContainer/HBoxContainer/VBoxContainer2/ItemList

func _on_ship_selected(index):
	UIJoinGame.disabled = false


func _on_faction_select_item_selected(index):
	FACTION = factions[index]
	UIShipChoice.clear()
	for item in ships[FACTION]:
		UIShipChoice.add_icon_item(item[1])
	#UIShipChoice.select(-1)
	#UIShipChoice.disabled = false
