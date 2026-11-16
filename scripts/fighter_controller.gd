extends CharacterBody3D

signal health_changed(new_hp, max_hp)
signal stamina_changed(new_stamina, max_stamina)
signal fighter_ko(fighter_name)

@export var fighter_name: String = "Fighter"
@export var is_player: bool = true
@export var opponent: Node3D
@export var walk_speed_forward: float = 3.2
@export var walk_speed_backward: float = 2.4
@export var walk_speed_strafe: float = 2.7
@export var turn_speed: float = 14.0

@export var max_health: float = 100.0
@export var max_stamina: float = 100.0

var health: float = 100.0
var stamina: float = 100.0
var is_blocking: bool = false
var is_attacking: bool = false
var is_ko: bool = false

var current_strike: String = ""
var strike_timer: float = 0.0
var strike_duration: float = 0.0
var idle_anim_time: float = 0.0

# Skeleton & Bones
@onready var skel: Skeleton3D = find_child("Skeleton3D", true, false)
var base_poses: Dictionary = {}

var b_hips: int = -1
var b_spine: int = -1
var b_neck: int = -1
var b_head: int = -1

var b_left_arm: int = -1
var b_left_forearm: int = -1
var b_left_hand: int = -1

var b_right_arm: int = -1
var b_right_forearm: int = -1
var b_right_hand: int = -1

var b_left_upleg: int = -1
var b_left_leg: int = -1
var b_left_foot: int = -1

var b_right_upleg: int = -1
var b_right_leg: int = -1
var b_right_foot: int = -1

var hitbox_l_hand: Area3D
var hitbox_r_hand: Area3D
var hitbox_l_foot: Area3D
var hitbox_r_foot: Area3D

var hurtbox_body: Area3D
var hurtbox_head: Area3D

var is_mixamo: bool = false

func _ready() -> void:
	health = max_health
	stamina = max_stamina
	cache_bone_ids()
	setup_hitboxes()
	disable_all_hitboxes()

func cache_bone_ids() -> void:
	if not skel:
		return
	base_poses.clear()
	for i in range(skel.get_bone_count()):
		base_poses[i] = skel.get_bone_pose_rotation(i)
		
	is_mixamo = (skel.find_bone("mixamorig_Hips") >= 0)
	
	b_hips = find_bone_by_aliases(["Hips", "mixamorig_Hips"])
	b_spine = find_bone_by_aliases(["Spine", "mixamorig_Spine"])
	b_neck = find_bone_by_aliases(["Neck", "mixamorig_Neck"])
	b_head = find_bone_by_aliases(["Head", "mixamorig_Head"])
	
	b_left_arm = find_bone_by_aliases(["LeftArm", "mixamorig_LeftArm"])
	b_left_forearm = find_bone_by_aliases(["LeftForeArm", "mixamorig_LeftForeArm"])
	b_left_hand = find_bone_by_aliases(["LeftHand", "mixamorig_LeftHand"])
	
	b_right_arm = find_bone_by_aliases(["RightArm", "mixamorig_RightArm"])
	b_right_forearm = find_bone_by_aliases(["RightForeArm", "mixamorig_RightForeArm"])
	b_right_hand = find_bone_by_aliases(["RightHand", "mixamorig_RightHand"])
	
	b_left_upleg = find_bone_by_aliases(["LeftUpLeg", "mixamorig_LeftUpLeg"])
	b_left_leg = find_bone_by_aliases(["LeftLeg", "mixamorig_LeftLeg"])
	b_left_foot = find_bone_by_aliases(["LeftFoot", "mixamorig_LeftFoot"])
	
	b_right_upleg = find_bone_by_aliases(["RightUpLeg", "mixamorig_RightUpLeg"])
	b_right_leg = find_bone_by_aliases(["RightLeg", "mixamorig_RightLeg"])
	b_right_foot = find_bone_by_aliases(["RightFoot", "mixamorig_RightFoot"])

func find_bone_by_aliases(aliases: Array[String]) -> int:
	for a in aliases:
		var idx = skel.find_bone(a)
		if idx >= 0:
			return idx
	return -1

func setup_hitboxes() -> void:
	if not skel:
		return
	hitbox_l_hand = create_bone_hitbox(b_left_hand, "Hitbox_LeftHand", 0.16)
	hitbox_r_hand = create_bone_hitbox(b_right_hand, "Hitbox_RightHand", 0.16)
	hitbox_l_foot = create_bone_hitbox(b_left_foot, "Hitbox_LeftFoot", 0.18)
	hitbox_r_foot = create_bone_hitbox(b_right_foot, "Hitbox_RightFoot", 0.18)
	
	# Hurtbox Body
	hurtbox_body = Area3D.new()
	hurtbox_body.name = "Hurtbox_Body"
	hurtbox_body.add_to_group("hurtbox")
	hurtbox_body.collision_layer = 2
	hurtbox_body.collision_mask = 4
	var col_b = CollisionShape3D.new()
	var cap = CapsuleShape3D.new()
	cap.radius = 0.30
	cap.height = 1.3
	col_b.shape = cap
	col_b.position = Vector3(0, 0.85, 0)
	hurtbox_body.add_child(col_b)
	add_child(hurtbox_body)
	
	# Hurtbox Head
	hurtbox_head = Area3D.new()
	hurtbox_head.name = "Hurtbox_Head"
	hurtbox_head.add_to_group("hurtbox")
	hurtbox_head.collision_layer = 2
	hurtbox_head.collision_mask = 4
	var col_h = CollisionShape3D.new()
	var sph = SphereShape3D.new()
	sph.radius = 0.22
	col_h.shape = sph
	col_h.position = Vector3(0, 1.58, 0)
	hurtbox_head.add_child(col_h)
	add_child(hurtbox_head)

func create_bone_hitbox(bone_idx: int, hitbox_name: String, radius: float) -> Area3D:
	if bone_idx < 0:
		return null
	var bone_name = skel.get_bone_name(bone_idx)
	var att = BoneAttachment3D.new()
	att.name = "Att_" + hitbox_name
	att.bone_name = bone_name
	att.bone_idx = bone_idx
	skel.add_child(att)
	
	var area = Area3D.new()
	area.name = hitbox_name
	area.collision_layer = 4
	area.collision_mask = 2
	area.monitoring = false
	
	var col = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = radius
	col.shape = sphere
	area.add_child(col)
	
	att.add_child(area)
	area.area_entered.connect(func(a): _on_hitbox_area_entered(a, area))
	return area

func _physics_process(delta: float) -> void:
	if is_ko:
		if not is_on_floor():
			velocity.y -= 15.0 * delta
		move_and_slide()
		return
		
	# 1. ALWAYS FOCUS / LOCK-ON OPPONENT (UFC 3 Undisputed style)
	if is_instance_valid(opponent):
		var target_pos = opponent.global_position
		target_pos.y = global_position.y
		var to_opp = target_pos - global_position
		if to_opp.length_squared() > 0.01:
			var target_rot_y = atan2(to_opp.x, to_opp.z)
			rotation.y = lerp_angle(rotation.y, target_rot_y, turn_speed * delta)
			
	# 2. Stamina Regeneration
	if not is_attacking and not is_blocking:
		stamina = min(max_stamina, stamina + delta * 22.0)
		stamina_changed.emit(stamina, max_stamina)
		
	# 3. Strike Timer Update
	if is_attacking:
		strike_timer -= delta
		if strike_timer <= 0.0:
			end_attack()
			
	# 4. Movement Handling (FIXED W/S and ANALOG INVERSION)
	if is_player:
		handle_player_movement(delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
		
	# 5. Gravity
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		velocity.y = 0.0
		
	move_and_slide()
	
	# 6. Procedural Orthodox Stance & Strike Animation
	idle_anim_time += delta
	update_procedural_pose(delta)

func handle_player_movement(delta: float) -> void:
	if is_attacking:
		velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
		return
		
	is_blocking = Input.is_action_pressed("block")
	
	# Read Analog Stick or WASD
	# In Godot, move_up gives negative Y, move_down gives positive Y
	var input_vec = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_vec.length_squared() > 0.01 and is_instance_valid(opponent):
		var cam = get_viewport().get_camera_3d()
		var cam_basis = cam.global_transform.basis if cam else Transform3D().basis
		var cam_fwd = -cam_basis.z
		var cam_rgt = cam_basis.x
		cam_fwd.y = 0.0
		cam_rgt.y = 0.0
		cam_fwd = cam_fwd.normalized()
		cam_rgt = cam_rgt.normalized()
		
		# INVERSION FIX:
		# W / Stick UP -> -input_vec.y is +1.0 (moves into screen / forward)
		# S / Stick DOWN -> -input_vec.y is -1.0 (moves towards camera / backward)
		var forward_amt = -input_vec.y
		var right_amt = input_vec.x
		var world_move_dir = (cam_fwd * forward_amt + cam_rgt * right_amt).normalized()
		
		var to_opp = (opponent.global_position - global_position).normalized()
		to_opp.y = 0.0
		var dot_forward = world_move_dir.dot(to_opp)
		
		var speed = walk_speed_strafe
		if dot_forward > 0.2:
			speed = walk_speed_forward
		elif dot_forward < -0.2:
			speed = walk_speed_backward
			
		if is_blocking:
			speed *= 0.5
			
		velocity.x = world_move_dir.x * speed
		velocity.z = world_move_dir.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, 12.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 12.0 * delta)
		
	# Attack Inputs
	if not is_blocking and not is_attacking:
		if Input.is_action_just_pressed("punch_left"):
			# X / J: Left Lead Jab (tay trước, nhanh gọn)
			execute_strike("jab_left", 14.0, 8.0, 0.22, hitbox_l_hand)
		elif Input.is_action_just_pressed("punch_right"):
			# Y / K: Right Rear Cross (tay sau, xoay hông, uy lực)
			execute_strike("cross_right", 24.0, 16.0, 0.32, hitbox_r_hand)
		elif Input.is_action_just_pressed("kick_left"):
			# A / U: Left Lead Body Kick (chân trước nhấc lên đá bụng, úp hông)
			execute_strike("lead_kick_left", 22.0, 18.0, 0.36, hitbox_l_foot)
		elif Input.is_action_just_pressed("kick_right"):
			# B / I: Right Rear Body Kick (chân sau đá sườn nhanh, lực vừa)
			execute_strike("rear_kick_right", 18.0, 14.0, 0.28, hitbox_r_foot)

func execute_strike(strike_name: String, dmg: float, stam_cost: float, duration: float, active_hitbox: Area3D) -> void:
	if stamina < stam_cost:
		dmg *= 0.55
		
	stamina = max(0.0, stamina - stam_cost)
	stamina_changed.emit(stamina, max_stamina)
	
	is_attacking = true
	current_strike = strike_name
	strike_duration = duration
	strike_timer = duration
	
	if is_instance_valid(opponent):
		var to_opp = (opponent.global_position - global_position).normalized()
		var lunge_speed = 2.4 if "kick" in strike_name else 2.8
		velocity += to_opp * lunge_speed
		
	disable_all_hitboxes()
	if active_hitbox:
		active_hitbox.set_deferred("monitoring", true)
		active_hitbox.set_meta("damage", dmg)
		active_hitbox.set_meta("strike_type", strike_name)

func end_attack() -> void:
	is_attacking = false
	current_strike = ""
	disable_all_hitboxes()

func disable_all_hitboxes() -> void:
	if hitbox_l_hand: hitbox_l_hand.set_deferred("monitoring", false)
	if hitbox_r_hand: hitbox_r_hand.set_deferred("monitoring", false)
	if hitbox_l_foot: hitbox_l_foot.set_deferred("monitoring", false)
	if hitbox_r_foot: hitbox_r_foot.set_deferred("monitoring", false)

# ------------------------------------------------------------------------------
# PROCEDURAL ANIMATION: ORTHODOX STANCE & STRIKES (UFC 3 UNDISPUTED STYLE)
# ------------------------------------------------------------------------------
func update_procedural_pose(delta: float) -> void:
	if not skel:
		return
		
	var breath = sin(idle_anim_time * 3.5) * 0.02
	
	# Base Guard Pose Deltas
	var d_hips = Quaternion.IDENTITY
	var d_spine = Quaternion.IDENTITY
	var d_l_arm = Quaternion.IDENTITY
	var d_l_forearm = Quaternion.IDENTITY
	var d_r_arm = Quaternion.IDENTITY
	var d_r_forearm = Quaternion.IDENTITY
	var d_l_leg = Quaternion.IDENTITY
	var d_l_knee = Quaternion.IDENTITY
	var d_r_leg = Quaternion.IDENTITY
	var d_r_knee = Quaternion.IDENTITY
	
	if is_mixamo:
		# Mixamo Male Mannequin
		d_l_arm = Quaternion.from_euler(Vector3(deg_to_rad(65.0), deg_to_rad(-25.0), deg_to_rad(-45.0 + breath * 15.0)))
		d_l_forearm = Quaternion.from_euler(Vector3(deg_to_rad(-75.0), deg_to_rad(20.0), 0.0))
		d_r_arm = Quaternion.from_euler(Vector3(deg_to_rad(65.0), deg_to_rad(25.0), deg_to_rad(45.0 - breath * 15.0)))
		d_r_forearm = Quaternion.from_euler(Vector3(deg_to_rad(-75.0), deg_to_rad(-20.0), 0.0))
		d_hips = Quaternion.from_euler(Vector3(0.0, deg_to_rad(20.0), 0.0))
		d_spine = Quaternion.from_euler(Vector3(0.0, deg_to_rad(-12.0), 0.0))
	else:
		# MPFB Female Character
		# Hands up guarding chin in Orthodox stance
		d_l_arm = Quaternion(Vector3(1, 0, 0), deg_to_rad(-35.0)) * Quaternion(Vector3(0, 1, 0), deg_to_rad(20.0)) * Quaternion(Vector3(0, 0, 1), deg_to_rad(-15.0 + breath * 20.0))
		d_l_forearm = Quaternion(Vector3(1, 0, 0), deg_to_rad(-65.0)) * Quaternion(Vector3(0, 1, 0), deg_to_rad(20.0))
		d_r_arm = Quaternion(Vector3(1, 0, 0), deg_to_rad(-30.0)) * Quaternion(Vector3(0, 1, 0), deg_to_rad(-20.0)) * Quaternion(Vector3(0, 0, 1), deg_to_rad(15.0 - breath * 15.0))
		d_r_forearm = Quaternion(Vector3(1, 0, 0), deg_to_rad(-75.0)) * Quaternion(Vector3(0, 1, 0), deg_to_rad(-20.0))
		d_hips = Quaternion(Vector3(0, 1, 0), deg_to_rad(18.0))
		d_spine = Quaternion(Vector3(0, 1, 0), deg_to_rad(-10.0))
		
	# High Guard (Block)
	if is_blocking:
		if is_mixamo:
			d_l_arm = Quaternion.from_euler(Vector3(deg_to_rad(55.0), deg_to_rad(-10.0), deg_to_rad(-25.0)))
			d_l_forearm = Quaternion.from_euler(Vector3(deg_to_rad(-105.0), 0.0, 0.0))
			d_r_arm = Quaternion.from_euler(Vector3(deg_to_rad(55.0), deg_to_rad(10.0), deg_to_rad(25.0)))
			d_r_forearm = Quaternion.from_euler(Vector3(deg_to_rad(-105.0), 0.0, 0.0))
		else:
			d_l_arm = Quaternion(Vector3(1, 0, 0), deg_to_rad(-55.0)) * Quaternion(Vector3(0, 1, 0), deg_to_rad(10.0))
			d_l_forearm = Quaternion(Vector3(1, 0, 0), deg_to_rad(-105.0))
			d_r_arm = Quaternion(Vector3(1, 0, 0), deg_to_rad(-55.0)) * Quaternion(Vector3(0, 1, 0), deg_to_rad(-10.0))
			d_r_forearm = Quaternion(Vector3(1, 0, 0), deg_to_rad(-105.0))
			
	# Attack Strike Poses: blended via bell curve (0 -> 1 -> 0)
	if is_attacking and strike_duration > 0.0:
		var progress = 1.0 - (strike_timer / strike_duration)
		var curve = sin(progress * PI)
		
		match current_strike:
			"jab_left":
				# X / J: Left Lead Jab (tay trước, nhanh gọn)
				var apex_la = Quaternion(Vector3(1, 0, 0), deg_to_rad(-75.0)) * Quaternion(Vector3(0, 1, 0), deg_to_rad(15.0))
				var apex_lfa = Quaternion(Vector3(1, 0, 0), deg_to_rad(-10.0))
				d_l_arm = d_l_arm.slerp(apex_la, curve)
				d_l_forearm = d_l_forearm.slerp(apex_lfa, curve)
				d_spine = d_spine.slerp(Quaternion(Vector3(0, 1, 0), deg_to_rad(5.0)), curve * 0.5)
				
			"cross_right":
				# Y / K: Right Rear Cross (tay sau, xoay hông, uy lực)
				var apex_hips = Quaternion(Vector3(0, 1, 0), deg_to_rad(-30.0))
				var apex_spine = Quaternion(Vector3(0, 1, 0), deg_to_rad(-25.0))
				var apex_ra = Quaternion(Vector3(1, 0, 0), deg_to_rad(-75.0)) * Quaternion(Vector3(0, 1, 0), deg_to_rad(-15.0))
				var apex_rfa = Quaternion(Vector3(1, 0, 0), deg_to_rad(-10.0))
				d_hips = d_hips.slerp(apex_hips, curve)
				d_spine = d_spine.slerp(apex_spine, curve)
				d_r_arm = d_r_arm.slerp(apex_ra, curve)
				d_r_forearm = d_r_forearm.slerp(apex_rfa, curve)
				
			"lead_kick_left":
				# A / U: Left Lead Body Kick (chân trước nhấc lên đá bụng, úp hông)
				var apex_hips = Quaternion(Vector3(0, 1, 0), deg_to_rad(-35.0)) * Quaternion(Vector3(1, 0, 0), deg_to_rad(10.0))
				var apex_spine = Quaternion(Vector3(0, 1, 0), deg_to_rad(-20.0))
				var apex_leg = Quaternion(Vector3(1, 0, 0), deg_to_rad(75.0)) * Quaternion(Vector3(0, 0, 1), deg_to_rad(25.0))
				var apex_knee = Quaternion(Vector3(1, 0, 0), deg_to_rad(-25.0))
				var apex_la = Quaternion(Vector3(1, 0, 0), deg_to_rad(30.0)) * Quaternion(Vector3(0, 0, 1), deg_to_rad(30.0))
				d_hips = d_hips.slerp(apex_hips, curve)
				d_spine = d_spine.slerp(apex_spine, curve)
				d_l_leg = d_l_leg.slerp(apex_leg, curve)
				d_l_knee = d_l_knee.slerp(apex_knee, curve)
				d_l_arm = d_l_arm.slerp(apex_la, curve * 0.8)
				
			"rear_kick_right":
				# B / I: Right Rear Body Kick (chân sau đá sườn nhanh, lực vừa)
				var apex_hips = Quaternion(Vector3(0, 1, 0), deg_to_rad(35.0)) * Quaternion(Vector3(1, 0, 0), deg_to_rad(8.0))
				var apex_spine = Quaternion(Vector3(0, 1, 0), deg_to_rad(20.0))
				var apex_r_leg = Quaternion(Vector3(1, 0, 0), deg_to_rad(70.0)) * Quaternion(Vector3(0, 0, 1), deg_to_rad(-25.0))
				var apex_r_knee = Quaternion(Vector3(1, 0, 0), deg_to_rad(-20.0))
				var apex_ra = Quaternion(Vector3(1, 0, 0), deg_to_rad(30.0)) * Quaternion(Vector3(0, 0, 1), deg_to_rad(-30.0))
				d_hips = d_hips.slerp(apex_hips, curve)
				d_spine = d_spine.slerp(apex_spine, curve)
				d_r_leg = d_r_leg.slerp(apex_r_leg, curve)
				d_r_knee = d_r_knee.slerp(apex_r_knee, curve)
				d_r_arm = d_r_arm.slerp(apex_ra, curve * 0.8)

	# Apply delta rotations to skeleton safely
	var blend_rate = 15.0 * delta
	apply_bone_delta(b_hips, d_hips, blend_rate, is_attacking)
	apply_bone_delta(b_spine, d_spine, blend_rate, is_attacking)
	apply_bone_delta(b_left_arm, d_l_arm, blend_rate, is_attacking)
	apply_bone_delta(b_left_forearm, d_l_forearm, blend_rate, is_attacking)
	apply_bone_delta(b_right_arm, d_r_arm, blend_rate, is_attacking)
	apply_bone_delta(b_right_forearm, d_r_forearm, blend_rate, is_attacking)
	apply_bone_delta(b_left_upleg, d_l_leg, blend_rate, is_attacking)
	apply_bone_delta(b_left_leg, d_l_knee, blend_rate, is_attacking)
	apply_bone_delta(b_right_upleg, d_r_leg, blend_rate, is_attacking)
	apply_bone_delta(b_right_leg, d_r_knee, blend_rate, is_attacking)

func apply_bone_delta(bone_id: int, delta_rot: Quaternion, blend_rate: float, direct: bool = false) -> void:
	if bone_id < 0 or not skel:
		return
	var base_rot: Quaternion = base_poses.get(bone_id, Quaternion.IDENTITY)
	var target_rot: Quaternion = base_rot * delta_rot
	if direct:
		skel.set_bone_pose_rotation(bone_id, target_rot)
	else:
		var cur: Quaternion = skel.get_bone_pose_rotation(bone_id)
		skel.set_bone_pose_rotation(bone_id, cur.slerp(target_rot, blend_rate))

# ------------------------------------------------------------------------------
# DAMAGE & REACTION
# ------------------------------------------------------------------------------
func take_damage(amount: float, hit_source_pos: Vector3, is_head: bool) -> void:
	if is_ko:
		return
		
	if is_blocking:
		amount *= 0.2
		stamina = max(0.0, stamina - amount * 0.8)
		stamina_changed.emit(stamina, max_stamina)
	else:
		var cam = get_viewport().get_camera_3d()
		if cam and cam.has_method("add_trauma"):
			cam.add_trauma(0.4 if is_head else 0.2)
			
	health = max(0.0, health - amount)
	health_changed.emit(health, max_health)
	
	var recoil_dir = (global_position - hit_source_pos).normalized()
	recoil_dir.y = 0.05
	velocity += recoil_dir * (amount * 0.3)
	
	if health <= 0.0:
		knockout(recoil_dir * (amount * 0.5))

func knockout(impulse: Vector3) -> void:
	is_ko = true
	disable_all_hitboxes()
	fighter_ko.emit(fighter_name)
	rotation.x = deg_to_rad(75.0)
	position.y = 0.2
	velocity = impulse

func _on_hitbox_area_entered(area: Area3D, hitting_box: Area3D) -> void:
	if area.is_in_group("hurtbox") and not is_ancestor_of(area):
		var target = area.owner
		if target and target.has_method("take_damage") and target != self:
			var dmg: float = hitting_box.get_meta("damage") if hitting_box.has_meta("damage") else 12.0
			var is_head = "Head" in area.name
			target.take_damage(dmg, hitting_box.global_position, is_head)
