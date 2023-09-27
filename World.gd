extends Node2D

func _on_chat_started(npc):
	$ChatControl.start_chat(npc.chat_prompt)
