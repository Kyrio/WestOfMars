class_name TalkButton
extends TextureButton


const TALK_ENABLED: CompressedTexture2D = preload("res://assets/ui/Button-Talk.png")
const TALK_DISABLED: CompressedTexture2D = preload("res://assets/ui/Button-Talk-disabled.png")
const LISTEN_ENABLED: CompressedTexture2D = preload("res://assets/ui/Button-Listen.png")
const LISTEN_DISABLED: CompressedTexture2D = preload("res://assets/ui/Button-Listen-disabled.png")


func show_as(heard: bool):
    var enabled_texture = LISTEN_ENABLED if heard else TALK_ENABLED
    var disabled_texture = LISTEN_DISABLED if heard else TALK_DISABLED
    
    if texture_normal != enabled_texture:
        texture_normal = enabled_texture
        texture_disabled = disabled_texture
    
    show()


func _on_dialogue_box_started_typing(needs_answer: bool):
    if needs_answer:
        visible = false
    else:
        visible = true
        disabled = true


func _on_dialogue_box_finished_typing(needs_answer: bool):
    if not needs_answer:
        disabled = false
