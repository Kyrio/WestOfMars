extends Sprite2D


@export var direction = Vector2(1, 0)
@export var speed = 300
@export var spin_speed = 1.0
@export var distance_to_go = Vector2(5760, 3240)
@export var start_after = 0.0


var time_since_reset = 0.0


@onready var initial_position = self.position


func _physics_process(delta):
    time_since_reset += delta
    
    if time_since_reset >= start_after:
        position += speed * delta * direction
        rotation += delta * spin_speed * (1 if direction.x >= 0 else -1)
    
        var distance_gone = abs(position - initial_position)
        if distance_gone > distance_to_go:
            position = initial_position
            time_since_reset = 0.0
            rotation = 0.0
