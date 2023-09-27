extends Node
class_name GPTClient

signal response_ready(messages)

export(String, MULTILINE) var prompt
export var completion_choices = 1

const API_KEY = "" # Put your API key here!

var http_request = HTTPRequest.new()
var message_history = []

func _ready():
	assert(!API_KEY.empty(), "missing API key")
	add_child(http_request)
	http_request.connect("request_completed", self, "_on_request_completed")
	message_history.append({
		"role": "system",
		"content": prompt
	})

func get_api_key():
	var path = "res://settings.json"
	
func add_history(message):
	message_history.append(message)

func request_dialog(options={}):
	var body = {
		"model": "gpt-3.5-turbo",
		"messages": message_history,
		"n": completion_choices,
	}
	for k in options.keys():
		body[k] = options[k]
	#print("Request:")
	#print(JSON.print(body, "\t"))
	var err = http_request.request("https://api.openai.com/v1/chat/completions",
		[ 
			"Content-Type: application/json",
			"Authorization: Bearer " + API_KEY
		],
		true,
		HTTPClient.METHOD_POST,
		JSON.print(body))

	if err != OK:
		printerr("Error making GPT request: %s" % err)

func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("GPT request failed: %s" % result)
		return
	var body_json = parse_json(body.get_string_from_utf8())
	#print("Response:")
	#print(JSON.print(body_json, "\t"))
	var messages = []
	for choice in body_json.choices:
		messages.append(choice.message)
	emit_signal("response_ready", messages)
