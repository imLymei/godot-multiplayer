extends Control


var peer: ENetMultiplayerPeer


@export var connection_address = "127.0.0.1"
@export var port = 3030
@onready var name_input: LineEdit = $MarginContainer/HBoxContainer/Name


func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.server_disconnected.connect(server_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	if "--server" in OS.get_cmdline_args():
		create_host()


func _exit_tree() -> void:
	multiplayer.peer_connected.disconnect(peer_connected)
	multiplayer.peer_disconnected.disconnect(peer_disconnected)
	multiplayer.server_disconnected.disconnect(server_disconnected)
	multiplayer.connected_to_server.disconnect(connected_to_server)
	multiplayer.connection_failed.disconnect(connection_failed)


func peer_connected(id) -> void:
	print("Player Connected: ", id)


func peer_disconnected(id) -> void:
	delete_player_information(id)
	var players = get_tree().get_nodes_in_group("player")
	
	for player in players:
		if player.name == str(id): player.queue_free()
	
	print("Player Disconnected: ", id)


func server_disconnected():
	multiplayer.multiplayer_peer = null
	peer = null
	GameManager.players = {}
	get_tree().root.get_node("World").queue_free()
	self.show()

func connected_to_server() -> void:
	send_player_information.rpc_id(1, name_input.text, multiplayer.get_unique_id())


func connection_failed() -> void:
	print("Connection Failed")

# any_peer => Anyone can call it
# call_local => Will NOT run on the local peer
@rpc("any_peer", "call_remote")
func send_player_information(name: String, id: int):
	if not GameManager.players.has(id):
		GameManager.players[id] = {"name": name, "id": id, "bangs": 0}
		
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_information.rpc(GameManager.players[i].name, i)


func delete_player_information(id: int):
	if GameManager.players.has(id):
		GameManager.players.erase(id)


# any_peer => Anyone can call it
# call_local => Will run on the local peer
@rpc("any_peer", "call_local")
func start_game():
	var scene = preload('res://scenes/world/world.tscn').instantiate()
	get_tree().root.add_child(scene)
	self.hide()


func create_host():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	
	if error != OK:
		print("Cannot Host: ", error)
		return
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer
	
	print("Waiting for Players!")


func _on_host_pressed() -> void: 
	create_host()
	send_player_information(name_input.text, multiplayer.get_unique_id())

func _on_join_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(connection_address, port)
	
	if error != OK:
		print("Cannot Connect: ", error)
		return
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer


func _on_start_game_pressed() -> void:
	# .rpc => Will call it in every peer
	start_game.rpc()
