extends Node2D

@onready var back_darken: Node2D = $"../Back/Darken"

func _ready():
	back_darken.modulate = Color.LIGHT_GRAY

func _on_main_char_enter_fade_ffg() -> void:
	var tween = $Fade.create_tween()
	var tween2 = back_darken.create_tween()
	print("entered fade_ffg")
	tween.tween_property($Fade, "self_modulate:a", 0.0, 0.15)
	tween2.tween_property(back_darken, "modulate", Color.WHITE, 0.2)

func _on_main_char_leave_fade_ffg() -> void:
	var tween = $Fade.create_tween()
	var tween2 = back_darken.create_tween()
	print("left fade_ffg")
	tween.tween_property($Fade, "self_modulate:a", 1.0, 0.15)
	tween2.tween_property(back_darken, "modulate", Color.LIGHT_GRAY, 0.2)
