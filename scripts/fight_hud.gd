extends CanvasLayer

@export var fighter_female: CharacterBody3D
@export var fighter_male: CharacterBody3D

@onready var p1_hp: ProgressBar = find_child("P1_HP", true, false)
@onready var p1_stam: ProgressBar = find_child("P1_Stam", true, false)
@onready var p2_hp: ProgressBar = find_child("P2_HP", true, false)

@onready var ko_banner: Label = find_child("KOBanner", true, false)
@onready var btn_restart: Button = find_child("BtnRestart", true, false)

@onready var stick_knob: Control = find_child("StickKnob", true, false)
@onready var lbl_jab: Label = find_child("Lbl_Jab", true, false)
@onready var lbl_cross: Label = find_child("Lbl_Cross", true, false)
@onready var lbl_kick_l: Label = find_child("Lbl_KickL", true, false)
@onready var lbl_kick_r: Label = find_child("Lbl_KickR", true, false)
@onready var lbl_block: Label = find_child("Lbl_Block", true, false)

func _ready() -> void:
	if ko_banner: ko_banner.visible = false
	if btn_restart:
		btn_restart.visible = false
		btn_restart.pressed.connect(func(): get_tree().reload_current_scene())
		
	if is_instance_valid(fighter_female):
		fighter_female.health_changed.connect(_on_p1_hp_changed)
		fighter_female.stamina_changed.connect(_on_p1_stam_changed)
		fighter_female.fighter_ko.connect(_on_ko)
		
	if is_instance_valid(fighter_male):
		fighter_male.health_changed.connect(_on_p2_hp_changed)
		fighter_male.fighter_ko.connect(_on_ko)

func _process(_delta: float) -> void:
	update_gamepad_display()

func update_gamepad_display() -> void:
	var move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if stick_knob:
		stick_knob.position = Vector2(24, 24) + move_input * 20.0
		
	highlight_label(lbl_jab, Input.is_action_pressed("punch_left"))
	highlight_label(lbl_cross, Input.is_action_pressed("punch_right"))
	highlight_label(lbl_kick_l, Input.is_action_pressed("kick_left"))
	highlight_label(lbl_kick_r, Input.is_action_pressed("kick_right"))
	highlight_label(lbl_block, Input.is_action_pressed("block"))

func highlight_label(lbl: Label, active: bool) -> void:
	if lbl:
		lbl.modulate = Color(1.0, 0.9, 0.2) if active else Color(0.65, 0.65, 0.65)

func _on_p1_hp_changed(hp: float, max_hp: float) -> void:
	if p1_hp: p1_hp.value = (hp / max_hp) * 100.0

func _on_p1_stam_changed(stam: float, max_stam: float) -> void:
	if p1_stam: p1_stam.value = (stam / max_stam) * 100.0

func _on_p2_hp_changed(hp: float, max_hp: float) -> void:
	if p2_hp: p2_hp.value = (hp / max_hp) * 100.0

func _on_ko(f_name: String) -> void:
	if ko_banner:
		ko_banner.text = "KNOCKOUT!\n" + f_name.to_upper() + " IS DOWN!"
		ko_banner.visible = true
	if btn_restart:
		btn_restart.visible = true
