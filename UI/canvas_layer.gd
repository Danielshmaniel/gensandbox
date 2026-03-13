extends CanvasLayer

@onready var inventory = $InventoryGui
@onready var hotbar = $HotbarGui

func _ready():
	inventory.close()
	hotbar.open()

func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		if inventory.isOpen:
			inventory.close()
			hotbar.open()
		else:
			hotbar.close()
			inventory.open()
