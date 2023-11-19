extends Label


func _process(delta: float) -> void:
	text = ""
	var new_text = ""
	
	for id in GameManager.players:
		new_text += "%s: %s\n" % [id, GameManager.players[id].name]
	
	text = new_text
