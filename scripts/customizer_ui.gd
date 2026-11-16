extends Control

@export var target_character: Node3D

@onready var sld_jaw_forward: HSlider = find_child("Sld_JawForward", true, false)
@onready var sld_jaw_open: HSlider = find_child("Sld_JawOpen", true, false)
@onready var sld_jaw_right: HSlider = find_child("Sld_JawRight", true, false)
@onready var sld_jaw_left: HSlider = find_child("Sld_JawLeft", true, false)

@onready var sld_nose_l: HSlider = find_child("Sld_NoseL", true, false)
@onready var sld_nose_r: HSlider = find_child("Sld_NoseR", true, false)

@onready var sld_brow_down_l: HSlider = find_child("Sld_BrowDownL", true, false)
@onready var sld_brow_down_r: HSlider = find_child("Sld_BrowDownR", true, false)
@onready var sld_brow_inner_up: HSlider = find_child("Sld_BrowInnerUp", true, false)

@onready var sld_cheek_puff: HSlider = find_child("Sld_CheekPuff", true, false)
@onready var sld_cheek_squint: HSlider = find_child("Sld_CheekSquint", true, false)
@onready var sld_eye_squint: HSlider = find_child("Sld_EyeSquint", true, false)

@onready var btn_ragdoll: Button = find_child("Btn_ToggleRagdoll", true, false)
@onready var btn_push: Button = find_child("Btn_Push", true, false)
@onready var btn_reset: Button = find_child("Btn_Reset", true, false)

func _ready() -> void:
	bind_slider(sld_jaw_forward, "jawForward")
	bind_slider(sld_jaw_open, "jawOpen")
	bind_slider(sld_jaw_right, "jawRight")
	bind_slider(sld_jaw_left, "jawLeft")
	
	bind_slider(sld_nose_l, "noseSneerLeft")
	bind_slider(sld_nose_r, "noseSneerRight")
	
	bind_slider(sld_brow_down_l, "browDownLeft")
	bind_slider(sld_brow_down_r, "browDownRight")
	bind_slider(sld_brow_inner_up, "browInnerUp")
	
	bind_slider(sld_cheek_puff, "cheekPuff")
	bind_slider(sld_cheek_squint, "cheekSquintLeft")
	bind_slider(sld_eye_squint, "eyeSquintRight")
	
	if btn_ragdoll:
		btn_ragdoll.pressed.connect(func():
			if target_character and target_character.has_method("toggle_ragdoll"):
				target_character.toggle_ragdoll()
		)
		
	if btn_push:
		btn_push.pressed.connect(func():
			if target_character and target_character.has_method("push_ragdoll"):
				target_character.push_ragdoll()
		)
		
	if btn_reset:
		btn_reset.pressed.connect(_on_reset_pressed)

func bind_slider(sld: HSlider, shape_name: String) -> void:
	if not sld:
		return
	sld.min_value = 0.0
	sld.max_value = 1.0
	sld.step = 0.01
	sld.value_changed.connect(func(val: float):
		if target_character and target_character.has_method("set_morph"):
			target_character.set_morph(shape_name, val)
	)

func _on_reset_pressed() -> void:
	if target_character and target_character.has_method("reset_all_morphs"):
		target_character.reset_all_morphs()
	for sld in [sld_jaw_forward, sld_jaw_open, sld_jaw_right, sld_jaw_left, sld_nose_l, sld_nose_r, sld_brow_down_l, sld_brow_down_r, sld_brow_inner_up, sld_cheek_puff, sld_cheek_squint, sld_eye_squint]:
		if sld:
			sld.set_value_no_signal(0.0)
