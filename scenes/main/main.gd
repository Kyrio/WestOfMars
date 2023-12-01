extends Node2D


const FADE_OUT = &"fade_out"

@onready var laugh_animation: AnimationPlayer = $LaughAnimation
@onready var transition_animation: AnimationPlayer = $TransitionAnimation

@onready var laugh_sfx: AudioStreamPlayer = $LaughSFX

@onready var dialogues_day0: Array[Node]
@onready var dialogues_day1: Array[Node]


func _ready():
    var tree = get_tree()
    dialogues_day0 = tree.get_nodes_in_group("areas_day0")
    dialogues_day1 = tree.get_nodes_in_group("areas_day1")
    
    Game.start_day()
    Scenes.ambience_base.play()
    Scenes.ambience_day.play()
    Scenes.music_gameplay.play()
    
    Game.day_ended.connect(_on_day_ended)


func _on_day_ended(_day: int):
    Scenes.music_gameplay.stop()
    Scenes.ambience_day.stop()
    Scenes.music_end_day.play()
    transition_animation.play("fade_out")


func _on_hud_laugh_starting():
    laugh_animation.play("laugh")
    laugh_sfx.play(0.3)


func _on_hud_laugh_ended():
    laugh_animation.play("RESET")


func _on_transition_animation_animation_finished(anim_name: StringName):
    if anim_name == FADE_OUT:
        Scenes.to_accusation()


func _on_hud_finished_dialogue():
    if Game.day > 1:
        # Unsupported!
        return
    
    var dialogue_array = dialogues_day0 if Game.day == 0 else dialogues_day1
    var is_dialogue_unread = false
    
    for node in dialogue_array:
        if node is DialogueArea and not node.played_once:
            is_dialogue_unread = true
            break
    
    if is_dialogue_unread:
        return
    
    Game.end_day()
