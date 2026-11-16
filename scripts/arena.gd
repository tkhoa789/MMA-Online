@tool
extends Node3D

@export var radius: float = 4.8
@export var wall_height: float = 1.9
@export var post_radius: float = 0.12

func _ready() -> void:
	build_octagon()

func build_octagon() -> void:
	# Clear existing procedural children
	for child in get_children():
		if child.name.begins_with("Procedural_"):
			child.queue_free()
			
	var container = Node3D.new()
	container.name = "Procedural_Octagon"
	add_child(container)
	
	# 1. Floor Mat
	var floor_body = StaticBody3D.new()
	floor_body.name = "FloorBody"
	container.add_child(floor_body)
	
	# Floor Collision (Cylinder)
	var floor_col = CollisionShape3D.new()
	var cyl_shape = CylinderShape3D.new()
	cyl_shape.radius = radius * 1.05
	cyl_shape.height = 0.4
	floor_col.shape = cyl_shape
	floor_col.position.y = -0.2
	floor_body.add_child(floor_col)
	
	# Floor Mesh (Octagon cylinder with 8 sides)
	var floor_mesh_inst = MeshInstance3D.new()
	var cyl_mesh = CylinderMesh.new()
	cyl_mesh.radial_segments = 8
	cyl_mesh.top_radius = radius
	cyl_mesh.bottom_radius = radius * 1.03
	cyl_mesh.height = 0.4
	
	var mat_floor = StandardMaterial3D.new()
	mat_floor.albedo_color = Color(0.12, 0.12, 0.14) # Canvas dark charcoal
	mat_floor.roughness = 0.85
	mat_floor.metallic = 0.05
	cyl_mesh.material = mat_floor
	
	floor_mesh_inst.mesh = cyl_mesh
	floor_mesh_inst.position.y = -0.2
	floor_body.add_child(floor_mesh_inst)
	
	# Floor Center Logo Ring
	var ring_inst = MeshInstance3D.new()
	var ring_mesh = TorusMesh.new()
	ring_mesh.inner_radius = 1.6
	ring_mesh.outer_radius = 1.68
	ring_mesh.rings = 32
	var mat_ring = StandardMaterial3D.new()
	mat_ring.albedo_color = Color(0.85, 0.15, 0.15) # Red ring line
	mat_ring.emission_enabled = true
	mat_ring.emission = Color(0.85, 0.15, 0.15) * 0.3
	ring_mesh.material = mat_ring
	ring_inst.mesh = ring_mesh
	ring_inst.position.y = 0.005
	container.add_child(ring_inst)
	
	# 2. 8 Wall segments and 8 Corner Posts
	var points: Array[Vector3] = []
	for i in range(8):
		var angle = i * (PI / 4.0) + (PI / 8.0)
		points.append(Vector3(cos(angle) * radius, 0.0, sin(angle) * radius))
		
	# Post Material (Padded foam)
	var mat_post_red = StandardMaterial3D.new()
	mat_post_red.albedo_color = Color(0.8, 0.1, 0.1) # Red corner
	mat_post_red.roughness = 0.4
	
	var mat_post_blue = StandardMaterial3D.new()
	mat_post_blue.albedo_color = Color(0.1, 0.3, 0.8) # Blue corner
	mat_post_blue.roughness = 0.4
	
	var mat_post_black = StandardMaterial3D.new()
	mat_post_black.albedo_color = Color(0.08, 0.08, 0.08) # Neutral black
	mat_post_black.roughness = 0.6
	
	# Fence Wireframe Material
	var mat_fence = StandardMaterial3D.new()
	mat_fence.albedo_color = Color(0.3, 0.3, 0.3, 0.4)
	mat_fence.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_fence.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_fence.metallic = 0.8
	mat_fence.roughness = 0.3
	
	for i in range(8):
		var p1 = points[i]
		var p2 = points[(i + 1) % 8]
		var mid = (p1 + p2) * 0.5
		var seg_len = p1.distance_to(p2)
		var wall_dir = (p2 - p1).normalized()
		var wall_angle = atan2(wall_dir.x, wall_dir.z)
		
		# Corner Post at p1
		var post = MeshInstance3D.new()
		var post_mesh = CylinderMesh.new()
		post_mesh.radial_segments = 16
		post_mesh.top_radius = post_radius
		post_mesh.bottom_radius = post_radius
		post_mesh.height = wall_height
		
		if i == 0:
			post_mesh.material = mat_post_red
		elif i == 4:
			post_mesh.material = mat_post_blue
		else:
			post_mesh.material = mat_post_black
			
		post.mesh = post_mesh
		post.position = p1 + Vector3(0, wall_height * 0.5, 0)
		container.add_child(post)
		
		# Wall Static Collision Body
		var wall_body = StaticBody3D.new()
		wall_body.name = "Wall_%d" % i
		wall_body.position = mid + Vector3(0, wall_height * 0.5, 0)
		wall_body.rotation.y = wall_angle
		
		var wall_col = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(0.08, wall_height, seg_len)
		wall_col.shape = box_shape
		wall_body.add_child(wall_col)
		
		# Wall Mesh (Semi-transparent Chain Link Mesh)
		var wall_mesh_inst = MeshInstance3D.new()
		var quad_mesh = QuadMesh.new()
		quad_mesh.size = Vector2(seg_len, wall_height)
		quad_mesh.material = mat_fence
		wall_mesh_inst.mesh = quad_mesh
		wall_mesh_inst.rotation.y = PI * 0.5
		wall_body.add_child(wall_mesh_inst)
		
		container.add_child(wall_body)
