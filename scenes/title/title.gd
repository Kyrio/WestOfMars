extends Control


@export var play_button: Button


func _ready():
    play_button.grab_focus()
    
    if not Scenes.music_title.playing:
        Scenes.music_title.play()


func _process(_delta):
    pass


func _on_play_pressed():
    Game.day = 0
    Scenes.music_title.stop()
    Scenes.to_main()


func _on_credits_pressed():
    Scenes.to_credits()
