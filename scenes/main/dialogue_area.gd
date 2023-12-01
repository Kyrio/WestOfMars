class_name DialogueArea
extends Area2D


@export var day = 0
@export var heard = false
@export var repeatable = false
@export var auto_trigger = false
@export var trigger_priority = 0
@export var characters_needed: Array[Types.Character]
@export var branch: DialogueBranch


var characters_present: Array[bool]
var player_present = false
var played_once = false


func _ready():
    if auto_trigger:
        repeatable = false
    
    for i in len(characters_needed):
        characters_present.push_back(false)
    
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)


func refresh_validity():
    if is_valid():
        if self not in Game.valid_dialogues:
            Game.valid_dialogues.push_back(self)
        
        return
    
    var index = Game.valid_dialogues.find(self)
    if index >= 0:
        Game.valid_dialogues.remove_at(index)


func is_valid():
    if not player_present:
        return false
    
    if played_once and not repeatable:
        return false
    
    if day != Game.day:
        return false
    
    if false in characters_present:
        return false
    
    return true


func _on_body_entered(body: Node2D):
    if body is Hero:
        player_present = true
        refresh_validity()
        return
    
    if body is NPC:
        var index = characters_needed.find(body.character)
        if index >= 0:
            characters_present[index] = true
            refresh_validity()


func _on_body_exited(body: Node2D):
    if body is Hero:
        player_present = false
        refresh_validity()
        return
    
    if body is NPC:
        var index = characters_needed.find(body.character)
        if index >= 0:
            characters_present[index] = false
            refresh_validity()
