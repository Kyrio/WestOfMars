class_name DialogueLine
extends Resource


const JUMBLE_MAP = {
    'A': 'U', 'a': 'u', 'E': 'Y', 'e': 'y', 'I': 'A', 'i': 'a', 'O': 'E', 'o': 'e',
    'U': 'I', 'u': 'i', 'Y': 'O', 'y': 'o', 'B': 'G', 'b': 'g', 'C': 'H', 'c': 'h',
    'D': 'J', 'd': 'j', 'F': 'K', 'f': 'k', 'G': 'L', 'g': 'l', 'H': 'M', 'h': 'm',
    'J': 'N', 'j': 'n', 'K': 'P', 'k': 'p', 'L': 'Q', 'l': 'q', 'M': 'R', 'm': 'r',
    'N': 'S', 'n': 's', 'P': 'T', 'p': 't', 'Q': 'V', 'q': 'v', 'R': 'W', 'r': 'w',
    'S': 'X', 's': 'x', 'T': 'Z', 't': 'z', 'V': 'B', 'v': 'b', 'W': 'C', 'w': 'c',
    'X': 'D', 'x': 'd', 'Z': 'F', 'z': 'f'
}


@export var character: Types.Character
@export var emotion: Types.Emotion
@export var emotion_about: Types.Character = Types.Character.NONE
@export_multiline var text: String
@export var remember_as = Types.Phrase.NONE
@export var reputation_modifier = 0
@export var saloon_laugh_at_end = false
@export var answer_branches: Array[DialogueBranch]


func get_jumbled_text() -> String:
    var jumbled_array = PackedStringArray()
    for letter in text:
        var jumbled = DialogueLine.JUMBLE_MAP.get(letter, letter)
        jumbled_array.append(jumbled)
    
    return "".join(jumbled_array)
