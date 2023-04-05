extends Node

@onready var map_node: Node2D = $MapNode
@onready var lbl_seed: Label = $Camera2D/UI/VBC/HBC/PC/VBC/Seed
@onready var map_size_node: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/MapSize/SpinBox
# Height Map vars
@onready var height_noise_type: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/NoiseType/SpinBox
@onready var height_fractal_type: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/FractalType/SpinBox
@onready var height_freqeuncy_limit: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/Frequency/SpinBox
# Temp Map vars
@onready var temp_noise_type: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/NoiseType2/SpinBox
@onready var temp_fractal_type: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/FractalType2/SpinBox
@onready var temp_freqeuncy_limit: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/Frequency2/SpinBox

@onready var globals = get_node("/root/Globals")
@onready var hex_scene = preload("res://scenes/hex_tile.tscn")

const max_size: int = 100
@export_range(10, max_size) var map_size : int = 10
@export var map_scale : float = 1
@export_group("Height Map Settings")
@export_range(0,1) var deep_water : float = 0.1 
@export_range(0,1) var mid_water : float = 0.3 
@export_range(0,1) var shallow_water : float = 0.45
@export_range(0,100) var flower_chance : int = 25
@export_range(0,5) var height_noise : int = 0
@export_range(0,3) var height_fractal : int = 0
@export_range(1, 100) var height_frequency : int = 1
@export_group("Temperature Map Settings")
@export_range(0,1) var snow: float = 0.1
@export_range(0,1) var tundra: float = 0.3
@export_range(0,1) var grassland: float = 0.7
@export_range(0,5) var temp_noise : int = 0
@export_range(0,3) var temp_fractal : int = 0
@export_range(1, 100) var temp_frequency : int = 1
@export_group("Hexagon Settings")
@export var tile_width: int = 126
@export var tile_height: int = 144

###
# Create a pool of hextiles that are used to build the map and reused on generation
# On map regen, compare map size to current hextiles
# If greater, create new hextiles
# If lesser, set excess tiles to null and [0,0]
###


func _ready():
	#Initial map generation
	SetUpTiles(max_size)
	InitialiseMap(map_size)

func _input(event):
	#Regenerate map on demand
	if event.is_action_pressed("reload"):
		_on_button_pressed()

func SetUpTiles(size: int):
	for i in range(size*size):
		var new_tile = hex_scene.instantiate()
		new_tile.position = Vector2(0, 0)
		map_node.add_child(new_tile)

func InitialiseMap(size: int):
	var world_map = await GenerateNewMap(size)
	SetMap(world_map)
	DrawMap()
	map_node.scale = Vector2(map_scale, map_scale)

func GenerateNewMap(size: int):
	var seed = randi()
	lbl_seed.text = "Seed: " + str(seed)
	var height_map: Image = await GenerateHeightMap(size, seed)
	var temp_map: Image = await GenerateTemperatureMap(size, seed)
	var world_map: Array = EvaluateWorldMap(height_map, temp_map, size)
	return world_map

func GenerateHeightMap(size: int, seed: int):
	# ----- || Gen Height Map || ----- #
	var height_map = NoiseTexture2D.new()
	height_map.noise = FastNoiseLite.new()
	height_map.noise.seed = seed
	height_map.noise.set_noise_type(height_noise)
	height_map.noise.set_fractal_type(height_fractal)
	height_map.noise.set_frequency(height_frequency/100.0)
	height_map.width = size
	height_map.height = size
	await height_map.changed
	var height_image = height_map.get_image()
	return height_image
	# ----- ||    Complete    || ----- #

func GenerateTemperatureMap(size: int, seed: int):
	# ----- || Gen Temp Map || ----- #
	var temp_map = NoiseTexture2D.new()
	temp_map.noise = FastNoiseLite.new()
	temp_map.noise.seed = seed
	temp_map.noise.set_noise_type(temp_noise)
	temp_map.noise.set_fractal_type(temp_fractal)
	temp_map.noise.set_frequency(temp_frequency/100.0)
	temp_map.width = size
	temp_map.height = size
	await temp_map.changed # causing freed object emitting signal error? prob engine issue
	var temp_image = temp_map.get_image()
	return temp_image
	# ----- ||   Complete   || ----- #

func EvaluateWorldMap(height_map: Image, temp_map: Image, size: int):
	# ----- World Map ----- #
	var world_map: Array = []
	for x in range(size):
		world_map.append([])
		for y in range(size):
			world_map[x].append(0)
	# ----- | Done! | ----- #
	
	# ----- Evaluate World ----- #
	for x in range(size):
		for y in range(size):
			var height = height_map.get_pixel(x, y).r
			var temp = temp_map.get_pixel(x, y).r
			
			if height < deep_water:
				world_map[x][y] = globals.TileType.OCEAN_DEEP
			elif height < mid_water:
				world_map[x][y] = globals.TileType.OCEAN_MID
			elif height < shallow_water:
				world_map[x][y] = globals.TileType.OCEAN_SHALLOW
			elif temp < snow:
				world_map[x][y] = globals.TileType.SNOW
			elif temp < tundra:
				world_map[x][y] = globals.TileType.TUNDRA
			elif temp < grassland:
				if randi()%100 < flower_chance:
					world_map[x][y] = globals.TileType.GRASSLAND_FLOWER
				else:
					world_map[x][y] = globals.TileType.GRASSLAND
			else:
				world_map[x][y] = globals.TileType.DESERT
	return world_map
	# ----- |    Done    | ----- #

func SetMap(world_map: Array):
	var index = 0
	for x in range(world_map.size()):
		for y in range(world_map.size()):
			map_node.get_child(index).SetTile(world_map[x][y], globals)
			index += 1
		index += (max_size - world_map.size())

func DrawMap():
	var size = sqrt(map_node.get_child_count())
	var index = 0
	for y in range(size):
		for x in range(size):
			var delta_x: int = (tile_width * x) + (tile_width/2 * (y%2))
			var delta_y: int = (tile_height/1.3 * y)
			var pos = Vector2(delta_x, delta_y)
			map_node.get_child(index).position = pos
			index += 1

func ClearMap():
	# Clear map by setting all tiles to null
	# This makes them recognised as "useless"
	for i in range(map_node.get_child_count()):
		map_node.get_child(i).SetTile(globals.TileType.NULL, globals)


func _on_button_pressed():
	# Adjust map size
	map_size = clamp(map_size_node.value, 10, max_size)
	# Adjust height map settings
	height_noise = height_noise_type.value
	height_fractal = height_fractal_type.value
	height_frequency = height_freqeuncy_limit.value
	# Adjust temp map settings
	temp_noise = temp_noise_type.value
	temp_fractal = temp_fractal_type.value
	temp_frequency = temp_freqeuncy_limit.value
	# Reload Map
	ClearMap()
	InitialiseMap(map_size)
