extends Node2D

@export var cutscenes: Array[PackedScene] = []   # Drag & drop your cutscene .tscn files here
@export var branch_a: Array[PackedScene] = []    # Optional branch A
@export var branch_b: Array[PackedScene] = []    # Optional branch B
@onready var container: Node2D = $Container

var current_index: int = 0
var current_cutscene: Node = null

func _ready():
	if cutscenes.size() > 0:
		_show_cutscene(0)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("p1_right"):
		print("RIGHT detected → calling _next_cutscene()")
		_next_cutscene()
	elif Input.is_action_just_pressed("p1_left"):
		print("LEFT detected → calling _prev_cutscene()")
		_prev_cutscene()


func _show_cutscene(index: int) -> void:
	if index < 0 or index >= cutscenes.size():
		return

	# Remove old cutscene if it exists
	if current_cutscene and is_instance_valid(current_cutscene):
		current_cutscene.queue_free()

	# Load new cutscene
	current_cutscene = cutscenes[index].instantiate()
	container.add_child(current_cutscene)
	current_index = index
	print("Showing cutscene:", index)

	# If this cutscene has a decision, connect to it
	if current_cutscene.has_signal("decision_made"):
		if not current_cutscene.is_connected("decision_made", Callable(self, "_on_decision_made")):
			current_cutscene.connect("decision_made", Callable(self, "_on_decision_made"))

func _next_cutscene() -> void:
	print("Current index:", current_index, " / Cutscenes total:", cutscenes.size())
	if current_index < cutscenes.size() - 1:
		_show_cutscene(current_index + 1)
	else:
		print("Reached end of cutscenes!")

func _prev_cutscene() -> void:
	print("Current index:", current_index, " / Cutscenes total:", cutscenes.size())
	if current_index > 0:
		_show_cutscene(current_index - 1)
	else:
		print("Already at first cutscene!")


func _on_decision_made(choice: String) -> void:
	print("Decision made:", choice)
	if choice == "A":
		cutscenes = branch_a
	elif choice == "B":
		cutscenes = branch_b

	# Reset index so it starts from beginning of new branch
	current_index = -1
	_next_cutscene()
