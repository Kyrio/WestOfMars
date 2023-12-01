extends Node


@export var title_scene: PackedScene
@export var credits_scene: PackedScene
@export var main_scene: PackedScene
@export var accusation_scene: PackedScene

@onready var ambience_base: AudioStreamPlayer = $AmbienceBase
@onready var ambience_day: AudioStreamPlayer = $AmbienceDay
@onready var ambience_night: AudioStreamPlayer = $AmbienceNight
@onready var music_title: AudioStreamPlayer = $MusicTitle
@onready var music_gameplay: AudioStreamPlayer = $MusicGameplay
@onready var music_end_day: AudioStreamPlayer = $MusicEndDay

var active_scene: Node


func _ready():
    var root = get_tree().root
    active_scene = root.get_child(root.get_child_count() - 1)


func _input(event: InputEvent):
    if event.is_action_pressed("toggle_fullscreen"):
        var window = get_tree().root
        window.mode = Window.MODE_FULLSCREEN if window.mode == Window.MODE_WINDOWED else Window.MODE_WINDOWED


func change_scene_to(path: String):
    var packed_scene = load(path) as PackedScene
    _deferred_change_scene_to.call_deferred(packed_scene)


func to_title():
    assert(title_scene)
    _deferred_change_scene_to.call_deferred(title_scene)


func to_credits():
    assert(credits_scene)
    _deferred_change_scene_to.call_deferred(credits_scene)


func to_main():
    assert(main_scene)
    _deferred_change_scene_to.call_deferred(main_scene)


func to_accusation():
    assert(accusation_scene)
    _deferred_change_scene_to.call_deferred(accusation_scene)


func _deferred_change_scene_to(packed_scene: PackedScene):
    active_scene.free()
    active_scene = packed_scene.instantiate()
    
    var tree = get_tree()
    tree.root.add_child(active_scene)
    tree.current_scene = active_scene
