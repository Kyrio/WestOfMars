class_name NPCFollow
extends PathFollow2D


@export var base_speed = 200
@export var loop_around_after = 10
@export var faces_right = false
@export var animated_sprite: AnimatedSprite2D

var character_body: CharacterBody2D

var _direction = 1
var _at_end = false
var _time_since_at_end = 0.0
var _former_position: Vector2


func _init():
    rotates = false
    loop = false


func _ready():
    _former_position = position
    
    for child in get_children():
        if child is CharacterBody2D:
            character_body = child
            break


func _physics_process(delta):
    if Game.paused:
        if animated_sprite:
            animated_sprite.pause()
        
        return
    
    if _at_end:
        _time_since_at_end += delta
        
        if _time_since_at_end > loop_around_after:
            _direction = - _direction
            _at_end = false
        
        return
    
    if animated_sprite:
        animated_sprite.play()
    
    progress += base_speed * delta * _direction
    
    if position.x > _former_position.x:
        character_body.scale.x = 1 if faces_right else -1
    elif position.x < _former_position.x:
        character_body.scale.x = -1 if faces_right else 1
    
    _former_position = position
    
    if progress_ratio <= 0.0 or progress_ratio >= 1.0:
        _at_end = true
        _time_since_at_end = 0.0
        
        if animated_sprite:
            animated_sprite.stop()
