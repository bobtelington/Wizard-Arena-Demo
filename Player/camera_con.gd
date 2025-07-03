extends Camera3D
class_name CameraCon

var target: Vector3

func mouse_to_3d():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var ray_start = project_ray_origin(mouse_pos)
	var ray_end = ray_start + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = ray_start
	ray_query.to = ray_end
	var result = space.intersect_ray(ray_query)
	
	print(result)
	
	if result.has("position"):
		target = result.position
	else:
		target = ray_end
