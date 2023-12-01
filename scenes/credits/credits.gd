extends Control


@export var back_button: Button


func _ready():
    back_button.grab_focus()


func _on_go_back_pressed():
    Scenes.to_title()
