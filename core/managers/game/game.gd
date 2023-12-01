extends Node


signal day_ended(day: int)

const PHRASE_EMOTIONS = [
    Types.Emotion.NONE,
    Types.Emotion.INNOCENCE,
    Types.Emotion.SADNESS,
    Types.Emotion.DISAGREEMENT,
    Types.Emotion.LAUGHTER,
    Types.Emotion.SUSPICION,
    Types.Emotion.AGREEMENT,
    Types.Emotion.RESPECT,
]

const DAY_DURATION = 240
const IDLE_PENALTY = 1
const IDLE_PENALTY_DELAY = 20

var day = 0
var day_seconds = 0
var understands_dialogue = false

var valid_dialogues: Array[DialogueArea] 
var active_dialogue: DialogueArea
var active_branch: DialogueBranch
var active_branch_line = 0

var known_phrases: Array[KnownPhrase] = [ KnownPhrase.new(Types.Phrase.SILENCE, null) ]

var time_since_last_new_dialogue = 0

var reputation: int:
    get:
        return _reputation
    set(value):
        _reputation = clampi(value, -70, 70)

var paused: bool:
    get:
        return _paused
    set(value):
        if day_timer:
            day_timer.paused = value
        _paused = value

var _reputation = 0
var _paused = false

@onready var day_timer: Timer = $DayTimer


func start_day():
    day_seconds = 0
    
    time_since_last_new_dialogue = 0
    valid_dialogues.clear()
    active_dialogue = null
    active_branch = null
    _paused = false
    
    day_timer.start()


func end_day():
    day_timer.stop()
    day_ended.emit(day)


func remember_phrase(line: DialogueLine) -> bool:
    for known_phrase in known_phrases:
        if known_phrase.phrase == line.remember_as:
            return false
    
    known_phrases.push_back(KnownPhrase.new(line.remember_as, line))
    return true


func get_day_percent() -> int:
    return floori(day_seconds * 100.0 / DAY_DURATION)


func _on_day_timer_timeout():
    day_seconds += 1
    time_since_last_new_dialogue += day_timer.wait_time
    
    if day_seconds >= DAY_DURATION:
        end_day()
        return
    
    if time_since_last_new_dialogue >= IDLE_PENALTY_DELAY:
        reputation -= IDLE_PENALTY


class KnownPhrase extends RefCounted:
    var phrase: Types.Phrase
    var line: DialogueLine
    
    func _init(p_phrase: Types.Phrase, p_line: DialogueLine):
        self.phrase = p_phrase
        self.line = p_line
