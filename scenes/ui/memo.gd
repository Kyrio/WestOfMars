class_name Memo
extends Panel


signal clicked_phrase(phrase: Types.Phrase)
signal dismissed(mode: int)

enum { MODE_MEMO, MODE_ANSWER_PICKER }

const PHRASE_BUTTON: PackedScene = preload("res://scenes/ui/phrase_button.tscn")

var mode: int:
    get = get_mode, set = set_mode

var _mode: int = MODE_MEMO

@export var title_label: Label
@export var phrase_list: VBoxContainer
@export var close_button: Button


func _input(event):
    if event.is_action_pressed("ui_cancel"):
        if visible:
            _on_close_pressed()


func update(emotion_icons: Array[CompressedTexture2D]):
    for child in phrase_list.get_children():
        child.free()

    for known_phrase in Game.known_phrases:
        var phrase_emotion = Game.PHRASE_EMOTIONS[known_phrase.phrase]
        
        var phrase_button: PhraseButton = PHRASE_BUTTON.instantiate()
        phrase_button.phrase = known_phrase.phrase
        phrase_button.icon = emotion_icons[phrase_emotion]

        if known_phrase.phrase == Types.Phrase.SILENCE:
            phrase_button.text = '“...”'
        elif Game.understands_dialogue:
            phrase_button.text = known_phrase.line.text
        else:
            phrase_button.text = known_phrase.line.get_jumbled_text()

        phrase_list.add_child(phrase_button)
        phrase_button.pressed.connect(_on_phrase_button_pressed.bind(phrase_button))


func get_mode() -> int:
    return _mode


func set_mode(value: int):
    if title_label and value != _mode:
        match value:
            MODE_MEMO:
                _mode = value
                title_label.text = "Memorized Phrases"
            MODE_ANSWER_PICKER:
                _mode = value
                title_label.text = "Click on a phrase to answer"


func set_focus():
    for child in phrase_list.get_children():
        if child is Button:
            child.grab_focus()
            return


func _on_phrase_button_pressed(phrase_button: PhraseButton):
    if _mode == MODE_MEMO:
        return
    
    clicked_phrase.emit(phrase_button.phrase)


func _on_close_pressed():
    dismissed.emit(_mode)
