extends Node2D


@export var player_scene: PackedScene


func _ready() -> void:
	var index = 1
	
	for i in GameManager.players:
		var actual_player = player_scene.instantiate() as Node2D
		actual_player.name = str(i)
		add_child(actual_player)
		
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint") as Array[Node2D]:
			if spawn.name == str(index):
				actual_player.global_position = spawn.global_position
		
		index += 1
