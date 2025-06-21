class_name DebugCamera	
extends Camera2D

"""
*** MAKE SURE TO ASSIGN INPUTS ***
- move_camera_left
- move_camera_right
- move_camera_up
- move_camera_down
"""

var zoom_speed: float = 0.1
var drag_sensitivity: float = 1.0
var camera_move_speed: float = 35
var target_zoom: Vector2 = Vector2(1.0, 1.0)
var lerp_weight: float = .25
var is_panning: bool = false

# # Decent values for real gameplay
# # Bigger numbers, closer to ground
# ## Smaller numbers, further out from ground
# var zoom_min: Vector2 = Vector2(0.5, 0.5)
# var zoom_max: Vector2 = Vector2(2, 2)

# # Dev values
var zoom_min: Vector2 = Vector2(0.1, 0.1)
var zoom_max: Vector2 = Vector2(2, 2)

# func _process(_delta):
	# print("Player Camera running")

# Consider moving to process
# May get laggy
func _physics_process(delta):
	if zoom != target_zoom:
		zoom = clamp(lerp(zoom, target_zoom, lerp_weight), zoom_min, zoom_max)

	var input_vector = Input.get_vector("move_camera_left", "move_camera_right", "move_camera_up", "move_camera_down")
	if input_vector != Vector2(0,0):
		is_panning = true
		var new_camera_vector = (input_vector * camera_move_speed) / zoom
		position += ((new_camera_vector * camera_move_speed) * delta)
	else:
		is_panning = false

func _input(event):

	# TODO: Make the camera zoom in and out smoothly

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var new_zoom = zoom + Vector2(zoom_speed, zoom_speed) # Used to surpress "zoom cannot be zero" 
			if new_zoom < zoom_max:
				target_zoom += Vector2(zoom_speed, zoom_speed)
			else:
				target_zoom = zoom_max
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var new_zoom = zoom - Vector2(zoom_speed, zoom_speed)
			if new_zoom > zoom_min:
				target_zoom -= Vector2(zoom_speed, zoom_speed)
			else: 
				target_zoom = zoom_min
				
	if not is_panning:
		if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			position -= (event.relative * drag_sensitivity) / zoom
			return