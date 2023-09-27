extends Area2D

signal interlocutor_changed(entity)

func _on_TalkBox_area_entered(area):
	emit_signal("interlocutor_changed", area)


func _on_TalkBox_area_exited(area):
	emit_signal("interlocutor_changed", null)
