class_name Hero
extends CharacterBody2D


@export var base_speed = 400

@onready var sprite: AnimatedSprite2D = $Sprite


func _process(_delta):
    if Game.paused:
        sprite.pause()
        return
    
    if velocity.length() > 0:
        sprite.play()
    else:
        sprite.stop()
    
    if velocity.x > 0:
        sprite.flip_h = true
    elif velocity.x < 0:
        sprite.flip_h = false


func get_input():
    var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_direction * base_speed


func _physics_process(_delta):
    if not Game.paused:
        get_input()
        move_and_slide()
