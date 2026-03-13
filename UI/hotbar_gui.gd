extends Control

signal opened
signal closed

var isOpen: bool = false
var selectedSlot: int = 0 # out of 8

@onready var inventory: Inventory = preload("res://Inventory/playerInventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

func _ready():
	update()
	slots[selectedSlot].get_child(0).frame = 1

func update():
	for i in range(min(inventory.items.size(), slots.size())):
		slots[i].update(inventory.items[i])

func _input(event):
	if event.is_action_pressed("cycle_hotbar_right") and not event.is_action_pressed("zoom_in"):
		if selectedSlot != 8:
			selectedSlot += 1
			slots[selectedSlot].get_child(0).frame = 1
			slots[selectedSlot-1].get_child(0).frame = 0
		else:
			selectedSlot = 0
			slots[selectedSlot].get_child(0).frame = 1
			slots[8].get_child(0).frame = 0
	if event.is_action_pressed("cycle_hotbar_left") and not event.is_action_pressed("zoom_out"):
		if selectedSlot != 0:
			selectedSlot -= 1
			slots[selectedSlot].get_child(0).frame = 1
			slots[selectedSlot+1].get_child(0).frame = 0
		else:
			selectedSlot = 8
			slots[selectedSlot].get_child(0).frame = 1
			slots[0].get_child(0).frame = 0

func open():
	visible = true
	isOpen = true
	opened.emit()

func close():
	visible = false
	isOpen = false
	closed.emit()
