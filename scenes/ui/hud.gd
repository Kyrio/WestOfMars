class_name HUD
extends Control


signal laugh_starting
signal laugh_ended
signal finished_dialogue

const DAY_NAMES = ["Day 1", "Day 2"]

@export var day_label: Label
@export var day_slider: HSlider
@export var scale_sprite: AnimatedSprite2D
@export var memo: Memo
@export var dialogue_box: DialogueBox
@export var talk_button: TalkButton
@export var talk_check: TextureRect
@export var emotion_icons: Array[CompressedTexture2D]

var priority_dialogue: DialogueArea

var _last_character = Types.Character.NONE

@onready var scale_animation_player = $ScaleAnimation


func _ready():
    memo.hide()
    memo.update(emotion_icons)
    dialogue_box.hide()


func _process(_delta):
    if not Game.active_dialogue:
        var max_priority = -1
        priority_dialogue = null
        
        for dialogue in Game.valid_dialogues:
            if dialogue.trigger_priority > max_priority:
                max_priority = dialogue.trigger_priority
                priority_dialogue = dialogue
        
        if priority_dialogue:
            talk_button.show_as(priority_dialogue.heard)
            talk_check.visible = priority_dialogue.played_once
                
            if priority_dialogue.auto_trigger:
                _on_talk_pressed()
        else:
            talk_button.hide()
            talk_check.hide()
    
    day_label.text = DAY_NAMES[Game.day]
    day_slider.value = Game.get_day_percent()
    Game.paused = (Game.active_dialogue or memo.visible)
    
    HUD.set_scale_frame(scale_sprite)


static func set_scale_frame(sprite: AnimatedSprite2D):
    if Game.reputation < -50:
        sprite.frame = 0
    elif Game.reputation < -30:
        sprite.frame = 1
    elif Game.reputation < -10:
        sprite.frame = 2
    elif Game.reputation < 10:
        sprite.frame = 3
    elif Game.reputation < 30:
        sprite.frame = 4
    elif Game.reputation < 50:
        sprite.frame = 5
    else:
        sprite.frame = 6
    

func _input(event: InputEvent):
    if event.is_action_pressed("open_memo"):
        if Game.active_dialogue:
            var line: DialogueLine = Game.active_branch.lines[Game.active_branch_line]
            
            if not line.answer_branches.is_empty():
                return
        
        if memo.visible:
            hide_memo()
        elif not dialogue_box.is_typing():
            show_memo(Memo.MODE_MEMO)
    
    elif event.is_action_pressed("ui_accept"):
        if talk_button.visible and not talk_button.disabled:
            talk_button.pressed.emit()

#    elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_R:
#        print(get_tree().root.gui_get_focus_owner())


func show_memo(mode: int):
    memo.mode = mode
    memo.set_focus()
    memo.show()
    talk_button.disabled = true


func hide_memo():
    memo.hide()
    talk_button.disabled = false
        

func continue_dialogue():
    var line: DialogueLine = Game.active_branch.lines[Game.active_branch_line]
    
    dialogue_box.show()
    dialogue_box.start_typing(line, emotion_icons, line.character != _last_character)
    _last_character = line.character


func _on_talk_pressed():
    hide_memo()
    
    if Game.active_dialogue:
        var line: DialogueLine = Game.active_branch.lines[Game.active_branch_line]
        if line.saloon_laugh_at_end:
            laugh_ended.emit()
        
        if Game.active_branch_line + 1 >= len(Game.active_branch.lines):
            if line.answer_branches.is_empty():
                # End of dialogue
                Game.active_dialogue.played_once = true
                
                if not Game.active_dialogue.repeatable:
                    Game.valid_dialogues.erase(Game.active_dialogue)
                
                Game.active_dialogue = null
                Game.active_branch = null
                
                _last_character = Types.Character.NONE
                dialogue_box.hide()
                
                finished_dialogue.emit()
                return
            else:
                # Choose your answer
                return
        
        Game.active_branch_line += 1
        continue_dialogue()
        return

    Game.active_dialogue = priority_dialogue
    Game.active_branch = priority_dialogue.branch
    Game.active_branch_line = 0
    talk_check.hide()
    
    if not priority_dialogue.played_once:
        Game.time_since_last_new_dialogue = 0
    
    continue_dialogue()


func _on_dialogue_box_finished_typing(_needs_answer: bool):
    var line = Game.active_branch.lines[Game.active_branch_line]
    
    if line.remember_as != Types.Phrase.NONE:
        if Game.remember_phrase(line):
            memo.update(emotion_icons)
        
    if line.reputation_modifier != 0 and not Game.active_dialogue.played_once:
        Game.reputation += line.reputation_modifier
        scale_animation_player.play("scale_bonus")
    
    if line.saloon_laugh_at_end:
        laugh_starting.emit()


func _on_dialogue_box_opened_answers():
    show_memo(Memo.MODE_ANSWER_PICKER)


func _on_memo_dismissed(_mode: int):
    hide_memo()


func _on_memo_clicked_phrase(phrase: Types.Phrase):
    hide_memo()
    
    var line: DialogueLine = Game.active_branch.lines[Game.active_branch_line]
    var next_branch: DialogueBranch = null
    
    for branch in line.answer_branches:
        if phrase in branch.selected_with:
            next_branch = branch
            break
    
    if not next_branch:
        for branch in line.answer_branches:
            if branch.selected_with.is_empty():
                next_branch = branch
                break

    if next_branch:
        Game.active_branch = next_branch
        Game.active_branch_line = 0
        continue_dialogue()


func _on_dialogue_box_next_pressed():
    if talk_button.visible and not talk_button.disabled:
        talk_button.pressed.emit()
