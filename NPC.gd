extends KinematicBody2D

signal chat_started(npc)

export(String, MULTILINE) var chat_prompt

func _on_TalkBox_interlocutor_changed(entity):
	$ChatButton.visible = entity != null

func _on_ChatButton_pressed():
	emit_signal("chat_started", self)
