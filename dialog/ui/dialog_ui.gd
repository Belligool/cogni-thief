extends CanvasLayer

@onready var bar: PanelContainer = $Bar
@onready var portrait: TextureRect      = $Bar/VBox/SpeakerRow/Portrait
@onready var speaker_name: Label        = $Bar/VBox/SpeakerRow/TextBlock/SpeakerName
@onready var dialog_text: RichTextLabel = $Bar/VBox/SpeakerRow/TextBlock/DialogText
@onready var choices_row: HBoxContainer = $Bar/VBox/ChoicesRow
