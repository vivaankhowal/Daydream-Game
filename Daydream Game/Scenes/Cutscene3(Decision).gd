extends Node2D

signal decision_made(choice: String)

@onready var label1: RichTextLabel = $Label1
@onready var label2: RichTextLabel = $Label2
@onready var button_a: Button = $Label2/ButtonA
@onready var button_b: Button = $Label2/ButtonB

var decision_stage: int = 0  # 0 = show intro (Label1), 1 = waiting for decision (Label2)

func _ready():
	if label1:
		label1.visible = true
	if label2:
		label2.visible = false

	# Connect button signals
	if button_a and not button_a.pressed.is_connected(_on_button_a_pressed):
		button_a.pressed.connect(_on_button_a_pressed)
	if button_b and not button_b.pressed.is_connected(_on_button_b_pressed):
		button_b.pressed.connect(_on_button_b_pressed)

func _process(delta: float) -> void:
	# If still in stage 0, wait for next arrow key input
	if decision_stage == 0:
		if Input.is_action_just_pressed("p1_right") or Input.is_action_just_pressed("cutscene_next"):
			_show_decision()

func _show_decision():
	if label1:
		label1.visible = false
	if label2:
		label2.visible = true
	decision_stage = 1  # now we are waiting for button press

func _on_button_a_pressed():
	print("Chose Path A")
	emit_signal("decision_made", "A")

func _on_button_b_pressed():
	print("Chose Path B")
	emit_signal("decision_made", "B")
