class_name BaseLayerGenerator
extends Node2D

var rng = RandomNumberGenerator.new()
var city: Array = []
var regions: Array[Region] = []

var radial_marker: PackedScene = preload("res://scenes/RadialMarker.tscn")
var grid_marker: PackedScene = preload("res://scenes/GridMarker.tscn")

class Region:
	var location: Vector2
	var region_type: GlobalData.RegionType
	var weight: float
	var angle: float
	func _init(_location: Vector2, _region_type: GlobalData.RegionType, _weight: float):
		location = _location
		region_type = _region_type
		weight = _weight # Decay rate; the lower the value, the more influence
		if region_type == GlobalData.RegionType.GRID:
			angle = [45,90].pick_random()

class Tensor:
	var a: float
	var b: float
	var c: float
	func _init(_a: float=0.0, _b: float=0.0, _c: float=0.0):
		a = _a
		b = _b
		c = _c
	func _to_string():
		return str("a: ", a,", b: ", b, " c: ",c )

func create_regions():
	create_grid_region()
	create_grid_region()
	create_radial_region()

func create_grid_region():
	# Create and store new grid region
	var pos: Vector2 = Vector2(rng.randi_range(0, GlobalData.width), rng.randi_range(0, GlobalData.height))
	var region: Region = Region.new(pos, GlobalData.RegionType.GRID, 1.0)
	regions.append(region)
	# Create and add new grid marker to world
	var marker: Sprite2D = grid_marker.instantiate()
	marker.position = region.location
	add_child(marker)

func create_radial_region():
	# Create and store new gradial region
	var pos: Vector2 = Vector2(rng.randi_range(0, GlobalData.width), rng.randi_range(0, GlobalData.height))
	var region: Region = Region.new(pos, GlobalData.RegionType.RADIAL, 1.0)
	regions.append(region)
	# Create and add new radial marker to world
	var marker: Sprite2D = radial_marker.instantiate()
	marker.position = region.location
	add_child(marker)

func create_base_layer():
	# Iterate through the grid, create a tensor at each point
	for y in range(GlobalData.height):
		city.append([])
		for x in range(GlobalData.width):
			var sum_a = 0.0
			var sum_b = 0.0
			var sum_c = 0.0
			var total_weight = 0.0
			var pos = Vector2(x,y)

			# Compute values from this point for each region
			for region in regions:
				var d = pos.distance_to(region.location)
				var w = exp(-d * region.weight)
				var theta = compute_theta(pos, region)

				sum_a += w * cos(2 * theta)	
				sum_b += w * sin(2 * theta)
				sum_c += -w * cos(2 * theta)
				total_weight += w

			if total_weight > 0:
				sum_a /= total_weight
				sum_b /= total_weight
				sum_c /= total_weight

			# Store the new Tensor at city[y][x]
			city[y].append(Tensor.new(sum_a, sum_b, sum_c))

func compute_theta(pos: Vector2, region: Region) -> float:
	if region.region_type == GlobalData.RegionType.GRID:
		return deg_to_rad(region.angle)
	elif region.region_type == GlobalData.RegionType.RADIAL:
		var delta: Vector2 = pos - region.location
		return atan2(delta.y, delta.x)
	else:
		push_error("Unsupported RegionType in compute_theta()")
		return 0.0

func _ready():
	create_regions()
	create_base_layer()

func _draw():
	const STEP = 10  # draw every 10 pixels
	for y in range(0, GlobalData.height, STEP):
		for x in range(0, GlobalData.width, STEP):
			var tensor = city[y][x]
			var angle = 0.5 * atan2(tensor.b, tensor.a)
			var dir = Vector2(cos(angle), sin(angle)) * 8
			var pos = Vector2(x, y)
			draw_line(pos, pos + dir, Color.RED, 1.0)