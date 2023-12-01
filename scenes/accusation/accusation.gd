extends Control


const ACCUSATION_NAME = &"accusation"
const SAFE_NAME = &"safe"
const WIN_NAME = &"win"
const LOSE_NAME = &"lose"
const FADE_IN_NAME = &"fade_in"

@onready var music_accusation: AudioStreamPlayer = $MusicAccusation
@onready var music_win: AudioStreamPlayer = $MusicWin
@onready var music_lose: AudioStreamPlayer = $MusicLose
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var scale_sprite: AnimatedSprite2D = %Scale

@onready var next_day_button: Button = %NextDay
@onready var back_button: Button = %BackToMenu
@onready var new_game_plus_button: Button = %NewGamePlus


func _ready():
    Scenes.ambience_night.play()
    animation_player.play(FADE_IN_NAME)


func _on_animation_player_animation_finished(anim_name: StringName):
    if anim_name == FADE_IN_NAME:
        music_accusation.play()
        animation_player.play(ACCUSATION_NAME)
    elif anim_name == ACCUSATION_NAME:
        _play_results()
    elif anim_name == SAFE_NAME:
        next_day_button.grab_focus()
    elif anim_name == WIN_NAME:
        back_button.grab_focus()
    elif anim_name == LOSE_NAME:
        back_button.grab_focus()


func _play_results():
    HUD.set_scale_frame(scale_sprite)
    
    if Game.reputation < -10:
        animation_player.play(LOSE_NAME)
        music_lose.play()
    else:
        if Game.day < 1:
            animation_player.play(SAFE_NAME)
        else:
            animation_player.play(WIN_NAME)
        
        music_win.play()


func _on_back_to_menu_pressed():
    Scenes.ambience_night.stop()
    Scenes.to_title()


func _on_next_day_pressed():
    Scenes.ambience_night.stop()
    Game.day = 1
    Scenes.to_main()


func _on_new_game_plus_pressed():
    Scenes.ambience_night.stop()
    Game.day = 0
    Game.understands_dialogue = true
    Scenes.to_main()
