extends CanvasLayer

@export var player: CharacterBody3D
@export var opponent: CharacterBody3D

@onready var p1_hp_bar: ProgressBar = $HUD/TopBar/P1_Box/HP_Bar
@onready var p1_stamina_bar: ProgressBar = $HUD/TopBar/P1_Box/Stamina_Bar
@onready var p2_hp_bar: ProgressBar = $HUD/TopBar/P2_Box/HP_Bar
@onready var ko_banner: Label = $HUD/KOBanner
@onready var btn_restart: Button = $HUD/BtnRestart

# Gamepad Debug Display
@onready var stick_indicator: Control = $HUD/GamepadHUD/StickBg/StickKnob
@onready var btn_x_lbl: Label = $HUD/GamepadHUD/BtnX
@onready var btn_y_lbl: Label = $HUD/GamepadHUD/BtnY
@onready var btn_a_lbl: Label = $HUD/GamepadHUD/BtnA
@onready var btn_b_lbl: Label = $HUD/GamepadHUD/BtnB
@onready var btn_block_lbl: Label = $HUD/GamepadHUD/BtnBlock

func _ready() -> void:
	ko_banner.visible = false
	btn_restart.visible = false
	btn_restart.pressed.connect(_on_restart_pressed)
	
	if is_instance_valid(player):
		player.health_changed.connect(_on_p1_health_changed)
		player.stamina_changed.connect(_on_p1_stamina_changed)
		player.fighter_ko.connect(_on_fighter_ko)
		
	if is_instance_valid(opponent):
		opponent.health_changed.connect(_on_p2_health_changed)
		opponent.fighter_ko.connect(_on_fighter_ko)

func _process(_delta: float) -> void:
	update_gamepad_debug()

func update_gamepad_debug() -> void:
	# Left Stick Motion
	var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if stick_indicator:
		stick_indicator.position = Vector2(25, 25) + dir * 22.0
		
	# Buttons
	set_btn_active(btn_x_lbl, Input.is_action_pressed("punch_left"))
	set_btn_active(btn_y_lbl, Input.is_action_pressed("punch_right"))
	set_btn_active(btn_a_lbl, Input.is_action_pressed("kick_left"))
	set_btn_active(btn_b_lbl, Input.is_action_pressed("kick_right"))
	set_btn_active(btn_block_lbl, Input.is_action_pressed("block"))

func set_btn_active(lbl: Label, active: bool) -> void:
	if lbl:
		lbl.modulate = Color(1.0, 0.9, 0.2) if active else Color(0.6, 0.6, 0.6)

func _on_p1_health_changed(hp: float, max_hp: float) -> void:
	if p1_hp_bar:
		p1_hp_bar.value = (hp / max_hp) * 100.0

func _on_p1_stamina_changed(stamina: float, max_stamina: float) -> void:
	if p1_stamina_bar:
		p1_stamina_bar.value = (stamina / max_stamina) * 100.0

func _on_p2_health_changed(hp: float, max_hp: float) -> void:
	if p2_hp_bar:
		p2_hp_bar.value = (hp / max_hp) * 100.0

func _on_fighter_ko(fighter_name: String) -> void:
	ko_banner.text = "KNOCKOUT!\n" + fighter_name.to_upper() + " DOWN!"
	ko_banner.visible = true
	btn_restart.visible = true

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
