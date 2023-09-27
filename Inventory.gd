extends Panel

var items = []

func _ready():
	update_item_list()

func add_item(item):
	items.append(item)
	update_item_list()

func remove_item(item):
	for i in range(items.size()):
		if items[i].item == item:
			items.remove(i)
			return

func get_description(item):
	for i in items:
		if i.item == item:
			return i.description
	return "an unknown item"

func update_item_list():
	$ItemList.clear()
	for item in items:
		$ItemList.add_item(item.item)
