extends WindowDialog

export(String, MULTILINE) var player_prompt
export(NodePath) var inventory_path

var npc_client
var player_client
onready var inventory = get_node(inventory_path)

func start_chat(prompt):
	npc_client = GPTClient.new()
	npc_client.prompt = prompt
	add_child(npc_client)
	player_client = GPTClient.new()
	player_client.prompt = player_prompt
	player_client.completion_choices = 3
	add_child(player_client)
	load_dialog()
	popup_centered()


func load_dialog():
	set_loading(true)

	var npc_functions = [
		{
			"name": "give_item",
			"description": "Give an item to the player",
			"parameters": {
				"type": "object",
				"properties": {
					"item": {
						"type": "string",
						"description": "A single word identifying the item, e.g. \"apple\"",
					},
					"description": {
						"type": "string",
						"description": "A human-readable description of the item, e.g. \"an enchanted sword\"",
					},
				},
				"required": ["item", "description"],
			},
		},
		{
			"name": "get_inventory",
			"description": "Get the contents of the player's inventory, including the item identifier and description",
			"parameters": {
				"type": "object",
				"properties": {},
			},
		},
		{
			"name": "take_item",
			"description": "Take an item from the player",
			"parameters": {
				"type": "object",
				"properties": {
					"item": {
						"type": "string",
						"description": "An item identifier (from the \"item\" field)",
					},
				},
				"required": ["item"],
			},
		},
	]
	var npc_text = ""
	var npc_done = false
	var loop_count = 0
	while npc_text.empty():
		loop_count += 1
		if loop_count > 3:
			print("GPT tried to loop too much!")
			return
		npc_client.request_dialog({ "functions": npc_functions })
		var npc_messages = yield(npc_client, "response_ready")
		var npc_message = npc_messages[0]
		npc_client.add_history(npc_message)
		if npc_message.content:
			npc_text += npc_message.content
			player_client.add_history({
				"role": "user",
				"content": npc_message.content,
			})
		if npc_message.has("function_call"):
			var fname = npc_message["function_call"]["name"]
			var args = parse_json(npc_message["function_call"]["arguments"])
			match [fname, args]:
				["give_item", { "item": var item, "description": var description }]:
					inventory.add_item(args)
					npc_text += "(You have been given %s)" % description
					player_client.add_history({
						"role": "system",
						"content": "You have just been given %s" % description
					})
				["get_inventory", _]:
					print("get_inventory called")
					npc_client.add_history({
						"role": "function",
						"name": "get_inventory",
						"content": JSON.print(inventory.items),
					})
				["take_item", { "item": var item }]:
					var description = inventory.get_description(item)
					npc_text += "(You gave them %s)" % description
					inventory.remove_item(item)
					player_client.add_history({
						"role": "system",
						"content": "You have just given them %s" % description
					})
	$VBoxContainer/Text.text = npc_text

	player_client.request_dialog()
	var player_messages = yield(player_client, "response_ready")
	$VBoxContainer/ReplyOptions.clear()
	for m in player_messages:
		$VBoxContainer/ReplyOptions.add_item(m.content)
	
	set_loading(false)


func set_loading(loading: bool):
	$VBoxContainer/Loading.visible = loading
	$VBoxContainer/Text.visible = !loading
	$VBoxContainer/ReplyOptions.visible = !loading



func _on_ReplyOptions_item_selected(index):
	var text = $VBoxContainer/ReplyOptions.get_item_text(index)
	npc_client.add_history({
		"role": "user",
		"content": text,
	})
	player_client.add_history({
		"role": "assistant",
		"content": text,
	})
	load_dialog()
