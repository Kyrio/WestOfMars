class_name DialogueBox
extends Control


signal started_typing(needs_answer: bool)
signal finished_typing(needs_answer: bool)
signal opened_answers
signal next_pressed


@export var character_tick = 0.03
@export var portraits: Array[CompressedTexture2D]

@export var npc_portrait: TextureRect
@export var text_label: Label
@export var answer_panel: Panel
@export var next_button: TextureButton

@export var emotion_bubble: TextureRect
@export var about_bubble: TextureRect
@export var emotion_rect: TextureRect
@export var about_character_rect: TextureRect
@export var choose_answer_button: Button

var _typing = false
var _time_since_last_tick: float
var _current_line: DialogueLine

@onready var bubble_animation_player = $BubbleAnimation
@onready var npc_animation_player = $NPCAnimation
@onready var arrow_animation_player = $ArrowAnimation


func _process(delta):
    if _typing:
        _time_since_last_tick += delta
        
        if _time_since_last_tick > character_tick:
            _time_since_last_tick = 0.0
            _on_character_tick()


func is_typing():
    return _typing


func start_typing(line: DialogueLine, emotion_icons: Array[CompressedTexture2D], new_character: bool):
    _current_line = line
    
    if line.character == Types.Character.NONE:
        npc_portrait.hide()
    else:
        npc_portrait.texture = portraits[line.character]
        
        if new_character:
            npc_animation_player.play("npc_slide")
    
    arrow_animation_player.stop()
    answer_panel.hide()
    emotion_bubble.hide()
    about_bubble.hide()
    next_button.hide()
    
    if line.emotion != Types.Emotion.NONE:
        _show_emotion(line, emotion_icons)
    
    if line.remember_as != Types.Phrase.NONE:
        text_label.add_theme_color_override("font_color", Color(1, 0.702, 0))
    elif line.reputation_modifier < 0:
        text_label.add_theme_color_override("font_color", Color(1, 0.318, 0.129))
    elif line.reputation_modifier > 0:
        text_label.add_theme_color_override("font_color", Color(0.529, 0.812, 0))
    else:
        text_label.remove_theme_color_override("font_color")
    
    if Game.understands_dialogue:
        text_label.text = line.text
    else:
        text_label.text = line.get_jumbled_text()
    
    text_label.visible_characters = 0
    
    _typing = true
    _time_since_last_tick = 0.0
    
    var needs_answer = len(_current_line.answer_branches) > 0
    started_typing.emit(needs_answer)


func _show_emotion(line: DialogueLine, emotion_icons: Array[CompressedTexture2D]):
    emotion_rect.texture = emotion_icons[line.emotion]
    
    if line.emotion_about != Types.Character.NONE:
        about_character_rect.texture = portraits[line.emotion_about]
        bubble_animation_player.play("emotion_about_pop")
    else:
        bubble_animation_player.play("emotion_pop")


func _on_character_tick():
    if text_label.visible_characters < text_label.get_total_character_count():
        text_label.visible_characters += 1
    else:
        _finish_typing()


func _finish_typing():
    _typing = false
    
    var needs_answer = len(_current_line.answer_branches) > 0
    if needs_answer:
        answer_panel.show()
        choose_answer_button.disabled = false
        choose_answer_button.focus_mode = FOCUS_ALL
        choose_answer_button.grab_focus()
    
    arrow_animation_player.play("arrow")
    finished_typing.emit(needs_answer)


func _on_choose_answer_pressed():
    choose_answer_button.disabled = true
    choose_answer_button.focus_mode = FOCUS_NONE
    opened_answers.emit()


func _on_memo_dismissed(mode: int):
    if mode == Memo.MODE_ANSWER_PICKER:
        choose_answer_button.disabled = false
        choose_answer_button.focus_mode = FOCUS_ALL
        choose_answer_button.grab_focus()


func _on_next_button_pressed():
    next_pressed.emit()
