extends CanvasLayer

@onready var skull_anim = $SkullAnim

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # 🔥 needed so it animates during pause
	skull_anim.visible = false

func play_skull_animation():
	skull_anim.visible = true
	skull_anim.play("skull")
