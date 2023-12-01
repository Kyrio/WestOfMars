class_name NPC
extends CharacterBody2D


@export var character: Types.Character


func _init():
    motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
